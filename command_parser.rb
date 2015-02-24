
class CommandParser < Contracted

  def initialize
    super

    addPreconditions
    addPostconditions
    addInvariants
  end

  # recursively expands all environment variables (i.e. $VARs).
  # pre takes string
  # post returns string, contains no matches for /$[^\s]+ /
  def substitute_vars(raw)
    raw
  end

  # detects and removes trailing ampersand, sets @is_background accordingly
  # pre takes string, must contain zero or one trailing " &"
  # post returns string, contains no trailing " &"
  def extract_background(raw)
    is_background = false

    [raw, is_background]
  end

  # detects and removes file output redirection, setting @out and @in
  # pre takes string, must contain zero or one file redirect operator,
  #     " > filename" or " >> filename"
  # post returns string, contains no " > " or " >> ", @stdin and @stdout
  #      respond to read and write, respectively
  def extract_io(raw)
    instream = $stdin
    outstream = $stdout

    [raw, instream, outstream]
  end

  #################################################
  ################### CONTRACTS ###################
  #################################################


  def addPreconditions
    takesString = Contract.new(
        "parameter must be a string",
        Proc.new do |raw|
          raw.is_a? String
        end
    )

    trailingAmpersand = Contract.new(
        "input string must have zero or one trailing ampersand",
        Proc.new do |raw|
          tmp = raw.sub(/\s+&$/, '')
          !(tmp =~ /\s+&$/)
        end
    )

    redirectOperator = Contract.new(
        "input string must have zero or one file redirect operations",
        Proc.new do |raw|
          tmp = raw.sub(/ >>?\s+[^\s]+/, '')
          puts tmp
          !(tmp =~ / >>?\s+[^\s]+/)
        end
    )

    addPrecondition(:substitute_vars, takesString)

    addPrecondition(:extract_background, takesString)
    addPrecondition(:extract_background, trailingAmpersand)

    addPrecondition(:extract_io, takesString)
    addPrecondition(:extract_io, redirectOperator)
  end

  def addPostconditions

    returnString = Contract.new(
        "return must be a string",
        Proc.new do |result|
          result.is_a? String
        end
    )

    returnStringBool = Contract.new(
        "return must be a string and a bool",
        Proc.new do |result|
          (result[0].is_a? String) && result[1] == !!result[1]
        end
    )

    returnStringStreams = Contract.new(
        "return must be a string and two streams",
        Proc.new do |result|
          (result[0].is_a? String) && (result[1].respond_to?(:read)) && (result[2].respond_to?(:write))
        end
    )

    noVariables = Contract.new(
        "expanded string must not contain environment variables",
        Proc.new do |result|
          !(result =~ /\$[^\s]+/)
        end
    )

    noBackgrounder = Contract.new(
        "result string must have zero trailing ampersand",
        Proc.new do |result|
          !(result =~ /\s+&$/)
        end
    )

    noRedirect = Contract.new(
        "result string must have zero file redirect operations",
        Proc.new do |result|
          !(result =~ / >>?\s+[^\s]+/)
        end
    )

    addPostcondition(:substitute_vars, returnString)
    addPostcondition(:substitute_vars, noVariables)

    addPostcondition(:extract_background, returnStringBool)
    addPostcondition(:extract_background, noBackgrounder)

    addPostcondition(:extract_io, returnStringStreams)
    addPostcondition(:extract_io, noRedirect)

  end

  def addInvariants

  end
end