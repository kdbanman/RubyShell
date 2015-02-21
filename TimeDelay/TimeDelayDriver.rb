require '../contracted.rb'
require './TimerContracts.rb'
require 'getoptlong'

class TimeDelayDriver < Contracted
	public
	attr_reader :message
	attr_reader :time

	def initialize
		super
		addPreconditions
		addPostconditions
		@opts = GetoptLong.new(
			['--help', '-h', GetoptLong::NO_ARGUMENT],
			['-s', GetoptLong::OPTIONAL_ARGUMENT],
			['-n', GetoptLong::OPTIONAL_ARGUMENT],
			['-m', GetoptLong::REQUIRED_ARGUMENT]
		)
		parseArgs
	end

	def parseArgs
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

			end
		end

		if ARGV.length != 1
  			puts "Missing dir argument (try --help)"
		  	exit 0
		end
		
	end

	def runTimer
	end 

	def addPreconditions
		inputIsInteger = Contract.new(
			"Input time must be an Integer",
			TimerContracts::INPUTISINTEGER
		)

		inputIsPositive = Contract.new(
			"Input time must be positive",
			TimerContracts::INPUTISPOSITIVE
		)

		inputIsString = Contract.new(
			"Input Message must be a String",
			Proc.new do |time, message|
				TimerContracts::INPUTISSTRING.call(message)
			end
		)

		addPrecondition(:runTimer, inputIsInteger)
		addPrecondition(:runTimer, inputIsPositive)
		addPrecondition(:runTimer, inputIsString)
	end

	def addPostconditions

	end

end

d = ContractRunner.new(TimeDelayDriver.new)
