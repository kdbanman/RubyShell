require './contracted.rb'
require './TimerContracts.rb'

class TimeDelayDriver < Contracted
	public
	attr_reader :message
	attr_reader :time

	def initialize
		addPreconditions
		addPostconditions
	end

	def parseArgs
	end

	def runTimer
	end 

	def addPreconditions
		inputIsInteger = Contract.New(
			"Input time must be an Integer",
			TimerContracts.inputIsInteger
		)

		inputIsPositive = Contract.new(
			"Input time must be positive",
			TimerContracts.inputIsPositive
		)

		inputIsString = Contract.new(
			"Input Message must be a String",
			Proc.new do |time, message|
				TimerContracts.inputIsString.call(message)
			end
		)

		addPrecondition(:runTimer, inputIsInteger)
		addPrecondition(:runTimer, inputIsPositive)
		addPrecondition(:runTimer, inputIsString)
	end

	def addPostconditions

	end

end
