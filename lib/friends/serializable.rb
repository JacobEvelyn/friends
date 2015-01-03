# Serializable provides functionality around serialization to the classes that
# extend it. This includes a class method to deserialize a string and create an
# instance of the class.

module Serializable
  # @param str [String] the serialized object string
  # @return [Object] the object represented by the serialized string
  # Note: this method assumes the calling class provides the following methods:
  #   - deserialization_regex
  #       a regex for the string which includes named parameters for the
  #       different initializer arguments
  #   - deserialization_expectation
  #       a string for what was expected, if the regex does not match
  def deserialize(str)
    match = str.match(deserialization_regex)

    unless match
      raise SerializationError,
            "Expected \"#{deserialization_expectation}\""
    end

    args = match.names.
           map { |name| { name.to_sym => match[name.to_sym] } }.
           reduce(:merge)

    new(args)
  end

  class SerializationError < StandardError
  end
end
