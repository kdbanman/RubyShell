require '../contracted.rb'
require './TimerContracts.rb'
require './delayc.so'

class TimeDelay < Contracted

	def initialize
		super
		addPreconditions
		addPostconditions
	end

	def delay(seconds, nanoseconds)
		err = Delayc.delay(seconds, nanoseconds)
		if (err == Errno::EFAULT::Errno)
			puts "Issue coping info from user space"
		elsif err == Errno::EINTR::Errno
			puts "Timer Interrupted!!"
		elsif err == Errno::EINVAL::Errno
			puts "Seconds or nanoseconds arg was invalid"
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

		addPrecondition(:delay, inputIsInteger)
		addPrecondition(:delay, inputIsPositive)
	end

	def addPostconditions
		# timeElapsedGreaterThanInput = Contract.new(
		# 	"Delayed time should be greater than passed time",
		# 	TimerContracts.timeElapsedGreaterThanInput
		# )

		# addPostcondition(:delay, timeElapsedGreaterThanInput)
	end
end

d = ContractRunner.new(TimeDelay.new)
d.delay(3, 1)
puts "Hello"