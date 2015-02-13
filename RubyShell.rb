#!/usr/bin/env ruby

class Command < Contracted

end

class RubyShell

	@history
	@builtins
	@env

	def initialize
		@history = Array.new
		@env = Hash.new
	end

	def run
		loop do
			command = getCommand()
			@history.push(command) # "feature": expanded commands remembered
			execute(command)
		end
	end

	def getCommand
		# TODO multiline input, history navigation, etc should go here.
		# TODO how do we intercept up/down to navigate history
		# TODO how do we actually display a history item

		$stdout.print '+> '
		$stdin.gets.strip

		# TODO expand command with . or .. or ~ or $VAR? or just let undershell handle that?
	end

	def execute(command)
		# TODO security: sanitize command?

		# TODO detect/execute builtin, else pid = fork { ...

		# TODO see Kernel::trap() for ctrl+c & others

		pid = spawn(@env, command, :unsetenv_others=>true)
		Process.wait pid

		# TODO security: restrict output?
	end

end

shell = RubyShell.new
shell.run
