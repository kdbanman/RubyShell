require './contracted.rb'
require './FileWatcherContracts.rb'

class FileWatcher < Contracted
	attr_reader :watched

	def initialize
		addPreconditions
		addPostConditions
	end	

	def FileWatchCreation(duration, *files, &action)
	end

    def FileWatchAlter(duration, *files, &action)
    end

    def FileWatchDestroy(duration, *files, &action)
    end

    def find_changes
    end

    def addPreconditions
		isDirectory = Contract.new(
			"Can only watch creations on directories",
			Proc.new do |x|
				x.each {FileWatcherContracts.isDirectory.call(x)}
			end
		)

		validPath = Contract.new(
			"All paths must exist in the files system",
			Proc.new do |x|
				x.each {FileWatcherContracts.pathExists.call(x)}
			end
		)

		simpleFile = Contract.new(
			"Path must lead to a regular file",
			Proc.new do |x|
				x.each {FileWatcherContracts.isSimpleFile.call(x)}
			end
		)

		blockPassed = Contract.new(
			"Must pass a block for this method to execute",
			Proc.new do |duration, files, action|
				FileWatcherContracts.isCallable.call(action)
			end
		)

		addPrecondition(:FileWatchCreation, validPath)
		addPrecondition(:FileWatchCreation, isDirectory)
		addPrecondition(:FileWatchCreation, blockPassed)

		addPrecondition(:FileWatchDestroy, validPath)
		addPrecondition(:FileWatchDestroy, isDirectory)
		addPrecondition(:FileWatchDestroy, blockPassed)

		addPrecondition(:FileWatchAlter, validPath)
		addPrecondition(:FileWatchAlter, simpleFile)
		addPrecondition(:FileWatchAlter, blockPassed)
	end

    def addPostconditions
    end
end

class Watched < Contracted
	attr_reader :path
	attr_reader :action
	
	def initialize (path, action)
		addPreconditions
		initVariables(path, action)
	end

	def initSuper(path, action)
		super.initialize(path, action)
	end	

	def initVariables(path, action)
		@path = path
		@action = action
	end

	def look_for_changes
	end

	def addPreconditions
		validPath = Contract.new(
			"All paths must exist in the files system",
				FileWatcherContracts.pathExists
		)

		blockPassed = Contract.new(
			"Must pass a block for this method to execute",
			Proc.new do |path, action|
				FileWatcherContracts.isCallable.call(action)
			end
		)

		addPrecondition(:initVariables, validPath);
		addPrecondition(:initVariables, blockPassed);
	end


end

class Directory < Watched
	attr_reader :paths

	def initialize(path, action)
		addPreconditions
		build_network
	end

	def look_for_changes
	end

	def build_network
	end

	def delete_path(path)
	end

	def add_path(path)
	end

	def addPreconditions
		isDirectory = Contract.new(
			"Must initialize a Directory with a path to a directory on disk",
			FileWatcherContracts.isDirectory
		)
		addPrecondition(:initSuper, isDirectory)
	end
end


class SimpleFile < Watched

	def initialize(path, action)
		initSuper(path, action)
		addPreconditions
	end

	def look_for_changes
	end

	def addPreconditions
		isFile = Contract.new(
			"Must initialize a SimpleFile with a path to a simple file on disk",
			FileWatcherContracts.isSimpleFile
		)
		addPrecondition(:initSuper, isDirectory)
	end
end


class Pipe < Watched

	def initialize(path, action)
		initSuper(path, action)
		addPreconditions
		addPostConditions
	end

	def look_for_changes
	end

	def addPreconditions
		isPipe = Contract.new(
			"Must initialize a Pipe with a path to a pipe on disk",
			FileWatcherContracts.isPipe
		)
		addPrecondition(:initSuper, isPipe)
	end
end