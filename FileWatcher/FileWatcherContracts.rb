require "./contracted"

module FileWatcherContracts
	def FileWatcherContracts.isDirectory(input, msg) 
		input.each do |f|
			failContract(msg) unless File.directory?(f)
		end
	end

	def FileWatcherContracts.pathExists (input, msg)
		input.each do |f|
			failContract(msg) unless File.exists?(f)
		end
	end

	def FileWatcherContracts.inputsAreIntegers(msg, *inputs)
		inputs.each do |i|
			failContract(msg) unless i.is_a? Integer
		end
	end

	def FileWatcherContracts.inputsArePositive(msg, *inputs)
		inputs.each do |i|
			failContract(msg) unless i >= 0
		end
	end

	def FileWatcherContracts.failContract(errMsg)
        ::Kernel.raise ::ContractFailure, errMsg
    end

end