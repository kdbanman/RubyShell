module TimerContracts
	inputIsInteger = Proc.new do |input|
		input.is_a? Integer 
	end

	inputIsPositive = Proc.new do |input|
		input > 0
	end

	inputIsString = Proc.new do |input|
		input.is_a? String
	end

	timeElapsedGreaterThanInput = Proc.new do |elapsed, expected|
		elapsed >= expected
	end

end