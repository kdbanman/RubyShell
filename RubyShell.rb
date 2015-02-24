require 'readline'
require './contracted'
require './command'

class RubyShell < Contracted

	private

	@builtins

	public

	def initialize
    super

    addPreconditions
    addPostconditions
    addInvariants

    add_builtins
  end

	# main shell REPL
  # pre @builtins is a hash
  # post none
	def run

		loop do
      begin
        cmdline = get_cmdline() # may exit program
        execute(cmdline)
      rescue ContractFailure => fail
        puts fail.msg
      rescue Errno::ENOENT => e
        puts :deeebug
        puts e.to_s
      rescue Errno::EACCES => e
        puts e.to_s
      rescue IOError => e
        puts "Illegal stdin state!"
        exit 1
      end
		end
	end

	private

  # tests if program is a builtin
  # pre program is a string containing no whitespace
  # post returns true or false
  def builtin?(raw)
    program = Shellwords.shellsplit(raw)[0].strip
    @builtins.has_key?(program)
  end

  # registers a builtin program
  # pre program is a string containing no whitespace
  #     runnable is a lambda proc taking the arguments for the builtin
  # post none
  def add_builtin(program, runnable)
    @builtins.store(program.strip, runnable)
  end

  # returns a runnable proc corresponding to the program
  # pre program is o string containing no whitespace
  # post returns a proc or nil
  def get_builtin(raw)
    program = Shellwords.shellsplit(raw)[0].strip
    @builtins[program]
  end

  def add_builtins
    @builtins = Hash.new

    add_builtin('export', Proc.new do |args|
                          var, value = args.split('=')
                          ENV[var] = value
                        end)

    add_builtin('cd', Proc.new { |dir| Dir.chdir(dir) })

    add_builtin('exit', Proc.new { |status = 0| exit(status.to_i) })
  end

	# gets a line of raw, unexpanded shell commands.
	# may contain pipes, output redirection, etc.
  # pre none
  # post returns either string or nil, string trimmed of whitespace
	def get_cmdline
    #TODO catch IOexception (see Readline website)
    begin
      cmdline = Readline.readline("+> ", true)
    rescue Interrupt => e
      puts "^C"
      cmdline = ""
    end

    exit if cmdline == nil

    cmdline.strip
  end

  # executes a string of raw input
  # pre takes a string (deeper contractual requirements are in deeper method calls)
  # post none
  def execute(cmdline)

    raw_pipeline = parse_pipeline(cmdline)
    cmd_pipeline = construct_pipeline(raw_pipeline)

    begin
      cmd_pipeline.each do |command|
        command.execute
      end
    rescue Interrupt => e
      puts ""
    end

  end

	# takes a line of command input and returns an array split on pipe characters
	# (does not split on pipe characters enclosed by quotes)
  # pre at most one output redirection to file (/ > [^\s]+/)
  #     output redirection to file (> or >>) follows all commands
  #     output redirection to file (> or >>) precedes optional backgrounder (&)
  # post returns array of strings
	def parse_pipeline(cmdline)
		cmdline.scan( /(?:".*?\"|[^|])+/ ).flatten.compact.collect { |cmd| cmd.strip }
	end

	# takes an array of command strings and maps them to an array of Commands
	# Commands are piped together with cmd[k].out chained to cmd[k+1].in
	# using IO.pipe
  # pre takes array of strings, IO.pipe returns array of IO
  # post returns array of Commands, each has .in.eof? true and .out.eof? false
  #      each command is tainted
	def construct_pipeline(raw_pipeline)
		pipeline = raw_pipeline.collect do |raw_cmd|
      if builtin? raw_cmd
        cmd = Command.new(raw_cmd, get_builtin(raw_cmd))
      else
        cmd = Command.new(raw_cmd)
      end

      ContractRunner.new(cmd)
    end

		# leave first command input and last command output alone. i.e. as
		# constructed by Command.new.  chain the rest together with pipes.
		(1...pipeline.length).each do |idx|
			rd, wr = IO.pipe
			pipeline[idx - 1].out = wr
			pipeline[idx].in = rd
		end

		pipeline
  end

  #################################################
  ################### CONTRACTS ###################
  #################################################

  def addPreconditions
    takesString = Contract.new(
        "parameter must be a string",
        Proc.new do |program|
          program.is_a? String
        end
    )

    takesStringRunnable = Contract.new(
        "parameters must be a string and a proc",
        Proc.new do |program, runnable|
          program.is_a?(String) && runnable.is_a?(Proc)
        end
    )

    redirectOperator = Contract.new(
        "entire command must have zero or one file redirect operations",
        Proc.new do |raw|
          tmp = raw.sub(/ >>?\s+[^\s]+/, '')
          !(tmp =~ / >>?\s+[^\s]+/)
        end
    )

    arrayStrings = Contract.new(
        "param must be array of strings",
        Proc.new do |param|
          param.is_a?(Array) && !(param.any? { |val| !val.is_a?(String)})
        end
    )

    addPrecondition(:builtin?, takesString)

    addPrecondition(:add_builtin, takesStringRunnable)

    addPrecondition(:get_builtin, takesString)

    addPrecondition(:execute, takesString)

    addPrecondition(:parse_pipeline, redirectOperator)

    addPrecondition(:construct_pipeline, arrayStrings)
  end

  def addPostconditions

    trueFalse = Contract.new(
      "must return true or false",
      Proc.new do |result|
        result == !!result
      end
    )

    procNil = Contract.new(
        "must return Proc or nil",
        Proc.new do |result|
          result.is_a?(Proc) || result.nil?
        end
    )

    trimmedString = Contract.new(
        "must return trimmed string",
        Proc.new do |result|
          result.is_a?(String) && result.strip.length == result.length
        end
    )

    arrayStrings = Contract.new(
        "result must be array of strings",
        Proc.new do |result|
          result.is_a?(Array) && !(result.any? { |val| !val.is_a?(String)})
        end
    )

    arrayCommands = Contract.new(
        "result must be array of commands",
        Proc.new do |result|
          result.is_a?(Array) && !(result.any? { |val| !val.is_a?(Command)})
        end
    )

    addPostcondition(:builtin?, trueFalse)

    addPostcondition(:get_builtin, procNil)

    addPostcondition(:get_cmdline, trimmedString)

    addPostcondition(:parse_pipeline, arrayStrings)

    addPostcondition(:construct_pipeline, arrayCommands)
  end

  def addInvariants

    builtinsHash =  Contract.new(
        "builtins must be a hash",
        Proc.new do
          @builtins.is_a? Hash
        end
    )

    builtinsStringProc = Contract.new(
        "builtins must be a hash of Strings to Procs",
        Proc.new do
          pass = true
          @builtins.each_pair do |key, val|
            pass &= key.is_a?(String)
            pass &= val.is_a?(Proc)
          end
          pass
        end
    )

    addInvariant(builtinsHash)
    addInvariant(builtinsStringProc)
  end

end