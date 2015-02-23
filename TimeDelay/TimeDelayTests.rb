gem "minitest"
require 'minitest/autorun'
require './contracted.rb'
require './TimeDelay/TimeDelay.rb'


class TimeDelayTests < Minitest::Test

	def setup
		@testObj = ContractRunner.new(TimeDelay.new)
	end

	def test_neg_seconds
		assert_raises(ContractFailure) {@testObj.delay(-3, 1)}
	end

	def test_neg_nano
		assert_raises(ContractFailure) {@testObj.delay(3, -1)}
	end

	def test_wrong_num_args
		assert_raises(ContractFailure) {@testObj.delay(3)}
	end

	def test_wrong_type_nano
		assert_raises(ContractFailure) {@testObj.delay(-3, "")}
	end

	def test_wrong_type_sec
		assert_raises(ContractFailure) {@testObj.delay("", 1)}
	end

	def test_trivial
		currTime = Time.now
		delaySeconds = 2
		@testObj.delay(delaySeconds, 1)
		assert(Time.now > currTime + delaySeconds)
	end

end