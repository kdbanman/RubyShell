require './FileWatcher/FileWatcher.rb'
require './contracted.rb'
require 'getoptlong'

class FileWatcherDriver < Contracted
	attr_reader :paths
	attr_reader :actions

	def initialize
		addPreconditions
		addPostConditions
		@actions = []
		@opts = GetoptLong.new(
			['--help', '-h', GetoptLong::NO_ARGUMENT],
			['-s', GetoptLong::REQUIRED_ARGUMENT],
			['-n', GetoptLong::REQUIRED_ARGUMENT],
			['-m', GetoptLong::REQUIRED_ARGUMENT],
			['-c', GetoptLong::NO_ARGUMENT],
			['-a', GetoptLong::NO_ARGUMENT],
			['-d', GetoptLong::NO_ARGUMENT]
		)
		parseArgs
		runActions
	end	

	def parseArgs
		if (ARGV.length == 0)
			puts "use --help"
			exit 0
		end

		begin
			@opts.each do |opt, arg|
				case opt
					when '--help'
					puts <<-eof
					FileWatcherDriver [OPTIONS]

					OPTIONS:
					========
					-s <seconds>
					-n <nanoseconds>
					-m <msg to print>
					-c (Watch for creations)
					-a (Watch for alterations)
					-d (Watch for deletions)
					eof
					exit(0)
					when '-s'
						@seconds = arg.to_i

					when '-n'
						@nanoseconds = arg.to_i
					when '-m'
						@message = arg
					when '-c'
						@actions << :watchCreations
					when '-a'
						@actions << :watchAlterations
					when '-d'
						@actions << :watchDeletions
				end
			end
		rescue GetoptLong::InvalidOption
			puts "Your arguments are not correct"
			exit 0
		rescue GetoptLong::MissingArgument
			puts "You are missing a value for a flag"
			exit 0	
		rescue GetoptLong::Error
			puts "Your input is malformed"
			exit 0 
		end

		if (ARGV.length < 1)
			puts "missing a path"
			exit 0
		end

		@paths = ARGV
	end

	def watchCreations(path)
		f = FileWatcher.new
		f.creation(@seconds, @nanoseconds, @paths) {puts @message}
	end

	def watchDeletions(path)
		f = FileWatcher.new
		f.destroy(@seconds, @nanoseconds, @paths) {puts @message}
	end

	def watchAlterations(path)
		f = FileWatcher.new
		f.alter(@seconds, @nanoseconds, @paths) {puts @message}
	end

	def runActions
		@actions.each do |action|
			fork {self.action(@paths)}
		end
	end

	def addPreconditions
		# isDirectory = Contract.new(
		# 	"Can only watch creations on directories",
		# 	FileWatcherContracts.isDirectory
		# )

		# validPath = Contract.new(
		# 	"All paths must exist in the files system",
		# 	FileWatcherContracts.pathExists
		# )

		# simpleFile = Contract.new(
		# 	"Path must lead to a regular file",
		# 	FileWatcherContracts.isSimpleFile
		# )

		# addPrecondition(:watchCreations, validPath)
		# addPrecondition(:watchCreations, isDirectory)

		# addPrecondition(:watchDeletions, validPath)
		# addPrecondition(:watchDeletions, isDirectory)

		# addPrecondition(:watchAlterations, validPath)
		# addPrecondition(:watchAlterations, simpleFile)
	end

	def addPostConditions
	end

end

FileWatcherDriver.new