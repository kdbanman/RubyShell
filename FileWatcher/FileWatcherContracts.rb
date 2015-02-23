module FileWatcherContracts
	isDirectory = Proc.new do |input|
		File.directory?(input)
	end

	isPipe = Proc.new do |input|
		File.pipe?(input)
	end

	isSimpleFile = Proc.new do |input|
		File.file?(input)
	end

	pathExists = Proc.new do |input|
		File.exists?(input)
	end

	isCallable = Proc.new do |input|
		input.respond_to? :call
	end

end