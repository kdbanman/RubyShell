require './contracted.rb'
require './TimerContracts.rb'

class TimeDelay

	def initialize
		addPreconditions
		addPostconditions
	end

	def delay(time)
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

		addPrecondition(:delay, inputIsInteger)
		addPrecondition(:delay, inputIsPositive)
	end

	def addPostconditions
		timeElapsedGreaterThanInput = Contract.new(
			"Delayed time should be greater than passed time",
			TimerContracts.timeElapsedGreaterThanInput
		)

		addPostcondition(:delay, timeElapsedGreaterThanInput)
	end


end