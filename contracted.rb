
# An invariant is a Proc that runs a test on object state.
# Returns true iff the test passes.
#
# EX: { @amounts.reduce(:+) <= @@MAX_SUM }
#
# A precondition is a Proc that runs a test on object state and/or
# method parameter.
# Returns true iff the test passes.
#
# EX: { |*parameters|  parameter[0].respond_to? :draw }
#     
# A postcondition is a Proc that runs a test on object state, return 
# value, and/or method parameters.
# Returns true iff the test passes.
#
# EX: { |returnVal, *parameters|  returnVal < @max }
#
#
# A Contract is made of a String message describing the contract, and a Proc
# contract that matches one of the 3 above.
class Contract
    attr_reader :contract, :message

    private
    @contract
    @message

    def initialize(message, contract)
        @message = message
        @contract = contract
    end
end

class Contracted

    #TODO this was written before Contracts were an object with an associated
    #message.  it should be refactored to match.

    private

    # Array of class invariants.
    @invariants

    # Hash from method names (Symbols) to method preconditions.
    @preconditions

    # Hash from method names (Symbols) to method postconditions.
    @postconditions

    # Hash from contracts (Procs) to warning labels (Strings)
    @contractLabels

    # Register an invariant for automatic verification
    # after every call.
    def addInvariant(invariant)
        getInvariants.push(invariant.contract)
        @contractLabels[invariant.contract] = invariant.message
    end

    # Register a precondition for automatic verification
    # before every call.
    def addPrecondition(method, precondition)
        getPreconditions(method).push(precondition.contract)
        @contractLabels[precondition.contract] = precondition.message
    end

    # Register a postcondition for automatic verification
    # after every call.
    def addPostcondition(method, postcondition)
        getPostconditions(method).push(postcondition.contract)
        @contractLabels[postcondition.contract] = postcondition.message
    end

    public

    def initialize(*args)
        @invariants = Array.new
        @preconditions = Hash.new
        @postconditions = Hash.new
        @contractLabels = Hash.new
    end

    def getInvariants
        @invariants
    end

    def getPreconditions(method)
        @preconditions[method] = @preconditions[method] || Array.new
    end

    def getPostconditions(method)
        @postconditions[method] = @postconditions[method] || Array.new
    end

    def getContractLabel(contract)
        @contractLabels[contract]
    end

end

class ContractFailure < StandardError
    
    alias_method :set_backtrace_old, :set_backtrace

    def initialize(msg)
        super "\n" + msg + "\n"
    end

    def set_backtrace(backtrace)
        #TODO this is fragile.  it should reliably remove all contracted.rb
        #elements of the backtrace, regardless of contracted.rb filename...
        trimmed_backtrace = backtrace.delete_if do |s|
            s.include? "contracted.rb" 
        end
        set_backtrace_old(trimmed_backtrace)
        #set_backtrace_old(backtrace)
    end
end

class ContractRunner < BasicObject

    private

    @contractedObject

    public

    def initialize(contracted)
        @contractedObject = contracted

        # TODO verify that target responds to getPreconditions(:method)
        # containing Enumerable of Procs.  i.e. inherits Contracted
    end

    private

    def perr(*args)
        ::Kernel.STDERR.puts(*args)
    end

    def failContract(errMsg)
        ::Kernel.raise ::ContractFailure, errMsg
    end

    # Intercept method call to intended object.
    # Run preconditions, postconditions, invariants
    def method_missing(method, *args, &block)

        verifyPreconditions(method, *args)

        returnValue = @contractedObject.send(method, *args, &block)

        verifyPostconditions(method, returnValue, *args)

        verifyInvariants()
        
        returnValue
    end

    #TODO verify*() should be refactored to use verifyContracts() somehow. the
    #repetition is ugly.
    #
    #TODO understanding runtime errors in contract blocks requires knowledge of
    #implementation here.  should try/catch ContractFailure and general
    #Exception in verifyContracts() above.  Add message info to general
    #Exception

    def verifyInvariants()
        @contractedObject.getInvariants().each do |invariant|
            if !invariant.call
                failContract "Invariant Failure: " +
                    @contractedObject.getContractLabel(invariant)
            end
        end
    end

    def verifyPreconditions(method, *args)
        # TODO preconditions on passed block...?
        @contractedObject.getPreconditions(method).each do |precondition|
            if !precondition.call(*args)
                failContract method.to_s + ": Precondition Failure: " + 
                    @contractedObject.getContractLabel(precondition)
            end
        end
    end

    def verifyPostconditions(method, returnValue, *args)
        # TODO on passed block...? is that a thing?
        @contractedObject.getPostconditions(method).each do |postcondition|
            if !postcondition.call(returnValue, *args)
                failContract method.to_s + ": Postcondition Failure: " + 
                    @contractedObject.getContractLabel(postcondition)
            end
        end
    end
end

