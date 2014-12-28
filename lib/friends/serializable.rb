module Serializable
  # @param str [String] the serialized object string
  # @return [Object] the object represented by the serialized string
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
