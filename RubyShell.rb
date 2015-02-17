require './contracted'
require './command'

class RubyShell

	private

	@history
	@builtins

	public

	def initialize
		@history = Array.new
	end

	# main shell REPL
	def run
		loop do
			cmdline = get_cmdline()
			@history.push(cmdline)
			execute(cmdline) if (valid_syntax(cmdline))
		end
	end

	private

	# gets a line of raw, unexpanded shell commands.
	# may contain pipes, output redirection, etc.
	def get_cmdline

		$stdout.print '+> '
				
		# TODO multiline input, history navigation, etc should go here.
		# TODO how do we intercept up/down to navigate history
		# TODO how do we actually display a history item

		$stdin.gets.strip

	end

	# verifies:
	# - trimmed of whitespace
	# - at most one output redirection to file
	# - output redirection to file (> or >>) follows all commands
	# - output redirection to file (> or >>) precedes optional backgrounder (&)
	def valid_syntax(cmdline)
		true #TODO this should be precondition to execute!!
	end

	# takes a line of command input and returns an array split on pipe characters
	# (does not split on pipe characters enclosed by quotes)
	def parse_pipeline(cmdline)
		cmdline.scan( /([^"'|]+)|["']([^"']+)["']/ ).flatten.compact
	end

	# takes an array of command strings and maps them to an array of Commands
	# Commands are piped together with cmd[k].out chained to cmd[k+1].in
	# using IO.pipe
	def construct_pipeline(raw_pipeline)
		pipeline = raw_pipeline.collect { |raw_cmd| Command.new(raw_cmd) }

		# leave first command input as default stdin, last command output as
		# default stdout.  chain the rest together.
		(1...pipeline.length).each do |idx|
			rd, wr = IO.pipe
			pipeline[idx - 1].out = wr
			pipeline[idx].in = rd
		end

		# TODO: ENV sub hint:
		# 'Is SHELL your preferred shell?'.sub(/[[:upper:]]{2,}/, ENV)
		pipeline
	end

	def execute(cmdline)

		raw_pipeline = parse_pipeline(cmdline)
		cmd_pipeline = construct_pipeline(raw_pipeline)

		
		cmd_pipeline.each do |command|
			command.execute
		end
		# TODO see Kernel::trap() for ctrl+c & others
	end

end