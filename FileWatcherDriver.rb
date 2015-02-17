require './FileWatcher.rb'
require './contracted.rb'

class FileWatcherDriver < Contracted
	attr_reader :paths


	def initialize
		addPreconditions
		addPostConditions
	end	

	def parseArgs
	end

	def watchCreations(path)
	end

	def watchDeletions(path)
	end

	def watchAlterations(path)
	end

	def init_actions
	end

	def addPreconditions
		isDirectory = Contract.new(
			"Can only watch creations on directories",
			FileWatcherContracts.isDirectory
		)

		validPath = Contract.new(
			"All paths must exist in the files system",
			FileWatcherContracts.pathExists
		)

		simpleFile = Contract.new(
			"Path must lead to a regular file",
			FileWatcherContracts.isSimpleFile
		)

		addPrecondition(:watchCreations, validPath)
		addPrecondition(:watchCreations, isDirectory)

		addPrecondition(:watchDeletions, validPath)
		addPrecondition(:watchDeletions, isDirectory)

		addPrecondition(:watchAlterations, validPath)
		addPrecondition(:watchAlterations, simpleFile)
	end

	def addPostConditions
	end

end