require '../contracted.rb'
require './TimerContracts.rb'
require './TimeDelay'
require 'getoptlong'

class TimeDelayDriver < Contracted
	public
	attr_reader :message
	attr_reader :seconds
	attr_reader :nanoseconds

	def initialize
		super
		addPreconditions
		addPostconditions
		@seconds = 0
		@nanoseconds = 0
		@opts = GetoptLong.new(
			['--help', '-h', GetoptLong::NO_ARGUMENT],
			['-s', GetoptLong::REQUIRED_ARGUMENT],
			['-n', GetoptLong::REQUIRED_ARGUMENT],
			['-m', GetoptLong::REQUIRED_ARGUMENT]
		)
		parseArgs
	end

	def parseArgs
		if (ARGV.length == 0)
			puts "use --help"
			exit 0
		end

		begin
			@opts.each do |opt, arg|
				case opt
					when '--help'
					puts <<-eof
					TimeDelayDriver [OPTIONS]

					OPTIONS:
					========
					-s <seconds>
					-n <nanoseconds>
					-m <msg to print>
					eof

					when '-s'
						@seconds = arg.to_i

					when '-n'
						@nanoseconds = arg.to_i
					when '-m'
						@message = arg

				end
			end
		rescue GetoptLong::InvalidOption
			puts "Your arguments are not correct"
			exit 0
		rescue GetoptLong::MissingArgument
			puts "You are missing a value for a flag"
			exit 0	
		rescue GetoptLong::Error
			puts "Your input is malformed"
			exit 0 
		end

		if (ARGV.length > 0)
			puts "use --help"
			exit 0
		end

	end

	def run
		i = ContractRunner.new(self)
		i.startTimer(@seconds, @nanoseconds, @message)
	end

	def startTimer (seconds, nanoseconds, message)
		fork do
			delayObj = ContractRunner.new(TimeDelay.new)
			delayObj.delay(seconds, nanoseconds)
			puts message
		end
	end 

	def addPreconditions
		inputIsInteger = Contract.new(
			"Input time must be an Integer",
			Proc.new {|sec, nan| TimerContracts::INPUTISINTEGER.call(sec) && TimerContracts::INPUTISINTEGER.call(nan)} 
		)

		inputIsPositive = Contract.new(
			"Input time must be positive",
			Proc.new {|sec, nan| TimerContracts::INPUTISPOSITIVE.call(sec) && TimerContracts::INPUTISPOSITIVE.call(nan)}
		)

		inputIsString = Contract.new(
			"Input Message must be a String",
			Proc.new do |sec, nan, message|
				TimerContracts::INPUTISSTRING.call(message)
			end
		)

		addPrecondition(:startTimer, inputIsInteger)
		addPrecondition(:startTimer, inputIsPositive)
		addPrecondition(:startTimer, inputIsString)
	end

	def addPostconditions

	end

end

d = ContractRunner.new(TimeDelayDriver.new)
d.run