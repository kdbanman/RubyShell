module TimerContracts
	INPUTISINTEGER = Proc.new do |input|
		input.is_a? Integer
	end

	INPUTISPOSITIVE = Proc.new do |input|
		input >= 0
	end

	inputIsString = Proc.new do |input|
		input.is_a? String
	end

	timeElapsedGreaterThanInput = Proc.new do |elapsed, expected|
		elapsed >= expected
	end

end