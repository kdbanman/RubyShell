
require 'shellwords'
require './contracted'

class Command < Contracted

  attr_accessor :in, :out

  attr_reader :is_background, :program, :args

  # output redirection to file and background processeing are dealt with here
  # at the command level, because each Command knows its I/O streams, and
  # each Command controls its own fork/exec/wait cycle
  #
  # valid raw examples:
  #   "cd .."
  #   "ruby -v"
  #   "cat file.txt"
  #   "echo $PATH"
  #   "grep "a | b" > file.txt &"
  def initialize(raw, runnable = nil)
    super

    addPreconditions
    addPostconditions
    addInvariants

    raw = substitute_vars(raw)
    raw = extract_background(raw)
    raw = extract_io(raw)

    @program, @args = Shellwords.shellsplit(raw)

    taint
  end

  # recursively expands all environment variables (i.e. $VARs).
  # pre takes string
  # post returns string, contains no matches for /$[^\s]+ /
  def substitute_vars(raw)
    raw
  end

  # detects and removes trailing ampersand, sets @is_background accordingly
  # pre takes string, must contain zero or one trailing " &"
  # post returns string, contains no trailing " &"
  def extract_background(raw)
    @is_background = false

    raw
  end

  # detects and removes file output redirection, setting @out and @in
  # pre takes string, must contain zero or one file redirect operator,
  #     " > filename" or " >> filename"
  # post returns string, contains no " > " or " >> ", @stdin and @stdout
  #      respond to read and write, respectively
  def extract_io(raw)
    @in = $stdin
    @out = $stdout

    raw
  end

  # forks and executes [and waits on] command as parsed.  manages I/O streams.
  # pre must be in $SAFE == 4, must be tainted
  # post @in and @out are closed unless they are $std*
  def execute
    pid = fork do
      unless @out == $stdout
        $stdout.reopen(@out)
        @out.close
      end

      unless @in == $stdin
        $stdin.reopen(@in)
        @in.close
      end

      exec @program, *@args # TODO detect if passed runnable proc, run that if so
    end

    @out.close unless @out == $stdout
    @in.close unless @in == $stdin

    Process.wait pid unless @is_background
  end

  #################################################
  ################### CONTRACTS ###################
  #################################################


  def addPreconditions
    takesString = Contract.new(
      "parameter must be a string",
      Proc.new do |raw|
        raw.is_a? String
      end
    )

    trailingAmpersand = Contract.new(
      "input string must have zero or one trailing ampersand",
      Proc.new do |raw|
        tmp = raw.sub(/\s+&$/, '')
        !(tmp =~ /\s+&$/)
      end
    )

    redirectOperator = Contract.new(
        "input string must have zero or one file redirect operations",
        Proc.new do |raw|
          tmp = raw.sub(/ >>?\s+[^\s]+/, '')
          !(tmp =~ / >>?\s+[^\s]+/)
        end
    )

    safeMode = Contract.new(
        "execution must happen in $SAFE level 4",
        Proc.new do |raw|
          $SAFE == 4
        end
    )

    addPrecondition(:substitute_vars, takesString)

    addPrecondition(:extract_background, takesString)
    addPrecondition(:extract_background, trailingAmpersand)

    addPrecondition(:extract_io, takesString)
    addPrecondition(:extract_io, redirectOperator)

    addPrecondition(:execute, safeMode)
  end

  def addPostconditions

    returnString = Contract.new(
        "return must be a string",
        Proc.new do |result|
          result.is_a? String
        end
    )

    noVariables = Contract.new(
        "expanded string must not contain environment variables",
        Proc.new do |result|
          !(result =~ /\$[^\s]+/)
        end
    )

    noBackgrounder = Contract.new(
        "result string must have zero trailing ampersand",
        Proc.new do |result|
          !(result =~ /\s+&$/)
        end
    )

    noRedirect = Contract.new(
        "result string must have zero file redirect operations",
        Proc.new do |result|
          !(result =~ / >>?\s+[^\s]+/)
        end
    )

    ioResponse = Contract.new(
        "object .in and .out must respond to read and write, respectively",
        Proc.new do
          @in.respond_to?(:read) && @out.respond_to?(:write)
        end
    )

    addPostcondition(:substitute_vars, returnString)
    addPostcondition(:substitute_vars, noVariables)

    addPostcondition(:extract_background, returnString)
    addPostcondition(:extract_background, noBackgrounder)

    addPostcondition(:extract_io, returnString)
    addPostcondition(:extract_io, noRedirect)
    addPostcondition(:extract_io, ioResponse)

  end

  def addInvariants
    tainted = Contract.new(
        "Command must be tainted",
        Proc.new do |raw|
          tainted?
        end
    )

    addInvariant(tainted)
  end

end