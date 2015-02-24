
require 'shellwords'
require './contracted'
require './command_parser'

class Command < Contracted

  attr_accessor :in, :out

  attr_reader :is_background, :program, :args, :runnable

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

    parser = ContractRunner.new(CommandParser.new)
    raw = parser.substitute_vars(raw)
    raw, @is_background = parser.extract_background(raw)
    raw, @in, @out = parser.extract_io(raw)

    @program, *@args = Shellwords.shellsplit(raw)

    @runnable = runnable

    taint
  end

  # forks and executes [and waits on] command as parsed.  manages I/O streams.
  # pre must be in $SAFE == 4, must be tainted TODO
  # post @in and @out are closed unless they are $std*
  def execute

    unless @out == $stdout
      orig_stdout = $stdout.clone
      $stdout.reopen(@out)
      @out.close
    end

    unless @in == $stdin
      orig_stdin = $stdin.clone
      $stdin.reopen(@in)
      @in.close
    end

    if runnable
      runnable.call(*@args)
    else
      pid = fork do
        exec @program, *@args
      end
      Process.wait pid unless @is_background
    end

    $stdin.reopen(orig_stdin) unless @out = $stdout
    $stdout.reopen(orig_stdout) unless @in == $stdin

  end

  #################################################
  ################### CONTRACTS ###################
  #################################################


  def addPreconditions

    #addPrecondition(:execute, safeMode)
  end

  def addPostconditions

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