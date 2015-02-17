require 'readline'
require './contracted'
require './command'

class RubyShell

	private

	@builtins

	public

	def initialize
    super

    addPreconditions
    addPostconditions
    addInvariants

    @builtins = Hash.new
	end

	# main shell REPL
  # pre @builtins is a hash
  # post none
	def run

		loop do
      #TODO catch ContractFailure
			cmdline = get_cmdline() # may exit program
			execute(cmdline) if (valid_syntax(cmdline))
		end
	end

	private

	# gets a line of raw, unexpanded shell commands.
	# may contain pipes, output redirection, etc.
  # pre none
  # post returns either string or nil, string trimmed of whitespace
	def get_cmdline
    #TODO catch ctrl c and IOexception (see Readline website)
    cmdline = Readline.readline("+> ", true)
    exit if cmdline == nil

    line.strip
  end

  # executes a string of raw input
  # pre takes a string (deeper contractual requirements are in deeper method calls)
  # post none
  def execute(cmdline)

    raw_pipeline = parse_pipeline(cmdline)
    cmd_pipeline = construct_pipeline(raw_pipeline)

    cmd_pipeline.each do |command|
      command.execute
    end

    # TODO see Kernel::trap() for ctrl+c & others
  end

	# takes a line of command input and returns an array split on pipe characters
	# (does not split on pipe characters enclosed by quotes)
  # pre at most one output redirection to file (/ > [^\s]+/)
  #     output redirection to file (> or >>) follows all commands
  #     output redirection to file (> or >>) precedes optional backgrounder (&)
  # post returns array of strings
	def parse_pipeline(cmdline)
		cmdline.scan( /([^"'|]+)|["']([^"']+)["']/ ).flatten.compact
	end

	# takes an array of command strings and maps them to an array of Commands
	# Commands are piped together with cmd[k].out chained to cmd[k+1].in
	# using IO.pipe
  # pre takes array of strings, IO.pipe returns array of IO
  # post returns array of Commands, each has .in.eof? true and .out.eof? false
  #      each command is tainted
	def construct_pipeline(raw_pipeline)
		pipeline = raw_pipeline.collect { |raw_cmd| Command.new(raw_cmd) }

		# leave first command input and last command output alone. i.e. as
		# constructed by Command.new.  chain the rest together with pipes.
		(1...pipeline.length).each do |idx|
			rd, wr = IO.pipe
			pipeline[idx - 1].out = wr
			pipeline[idx].in = rd
		end

		pipeline
	end

  def addPreconditions

  end

  def addPostconditions

  end

  def addInvariants

  end

end