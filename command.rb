
require 'shellwords'
require './contracted'

class Command < Contracted

  attr_accessor :in, :out

  attr_reader :is_background, :program, :args

  # valid raw:
  #   "cd .."
  #   "ruby -v"
  #   "cat file.txt"
  #   "echo $PATH"
  #   "grep "a | b" > file.txt &"
  def initialize(raw)
    super

    @in = $stdin
    @out = $stdout

    @is_background = false #TODO detect &

    @program, @args = Shellwords.shellsplit(raw)
  end

  def execute
    # TODO security: sandbox this method
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
    @in.close unless @in== $stdin

    Process.wait pid
  end

end