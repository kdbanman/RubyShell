require 'rb-inotify'
require './TimeDelay/TimeDelay.rb'
require './contracted.rb'

class FileWatch

	def initialize
		@userAction = Proc.new do |block, sec, nano|
			delay = ContractRunner.new(TimeDelay.new())
			delay.delay(sec,nano)
			block.call
		end
	end

	def creation(sec, nano, args, &block)
		notifier = INotify::Notifier.new
		args.each do |path|
			notifier.watch(path, :moved_to, :create) do
				fork do 
					@userAction.call(block, sec, nano)
				end
			end
		end
		notifier.run
	end

	def alter(sec, nano, args, &block)
		notifier = INotify::Notifier.new
		args.each do |path|
			notifier.watch(path, :access, :attrib, :modify, :delete) do
				fork do 
					@userAction.call(block, sec, nano)
				end
			end
		end
		notifier.run
	end

	def destroy(sec, nano, args, &block)
		notifier = INotify::Notifier.new
		args.each do |path|
			notifier.watch(path, :delete) do
				fork do 
					@userAction.call(block, sec, nano)
				end
			end
		end
		notifier.run
	end

	def test(sec, nano, *args, &block)
		fork do
			@userAction.call(block, sec, nano)
		end
	end

end

# f = FileWatch.new
# fork {f.creation(1,1,"."){puts "File was created!!!"}}
# fork {f.alter(1,1, "."){puts "File was altered!!!"}}
# fork {f.destroy(1,1,"."){puts "File was destroied!!!"}}