require './FileWatcher/FileWatcher.rb'
require './FileWatcher/FileWatcherContracts.rb'
require './contracted.rb'
require 'getoptlong'

class FileWatcherDriver < Contracted
	attr_reader :paths
	attr_reader :actions

	def initialize
		super
		@seconds = 0
		@nanoseconds = 0
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
FileWatcherDriver [OPTIONS] path1, path2, ... pathn

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
		FileWatcherContracts.pathExists(path, "Path Must Exist to watch Creations")
		FileWatcherContracts.isDirectory(path, "Can only watch for creations on Directories")

		f = FileWatch.new
		f.creation(@seconds, @nanoseconds, @paths) {puts @message || "File Created"}
	end

	def watchDeletions(path)
		FileWatcherContracts.pathExists(path, "Path Must Exist to watch deletions")
		FileWatcherContracts.isDirectory(path, "Can only watch for deletions on Directories")

		f = FileWatch.new
		f.destroy(@seconds, @nanoseconds, @paths) {puts @message || "File Deleted"}
	end

	def watchAlterations(path)
		FileWatcherContracts.pathExists(path, "Path Must Exist to watch alterations")

		f = FileWatch.new
		f.alter(@seconds, @nanoseconds, @paths) {puts @message || "File Altered"}
	end

	def runActions
		begin
			FileWatcherContracts.inputsAreIntegers("All times must be integers", @seconds, @nanoseconds)
			FileWatcherContracts.inputsArePositive("All times must be positive", @seconds, @nanoseconds)
		rescue ContractFailure
			puts $!.message
			exit(0)
		end	

		@actions.each do |action|
			puts action
			fork {ContractRunner.new(self).send(action, @paths)}
		end
	end

end

if __FILE__ == $0
	fw = FileWatcherDriver.new
	fw.runActions
end