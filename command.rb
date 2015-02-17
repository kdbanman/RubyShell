
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
  def initialize(raw)
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

      exec @program, *@args
    end

    @out.close unless @out == $stdout
    @in.close unless @in == $stdin

    Process.wait pid unless @is_background
  end

  def addPreconditions

  end

  def addPostconditions

  end

  def addInvariants

  end

end