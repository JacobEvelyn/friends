# Friend represents a friend. You know, a real-life friend!

require "friends/serializable"

module Friends
  class Friend
    extend Serializable

    SERIALIZATION_PREFIX = "- "

    # @return [Regexp] the regex for capturing groups in deserialization
    def self.deserialization_regex
      /(#{SERIALIZATION_PREFIX})?(?<name>.+)/
    end

    # @return [Regexp] the string of what we expected during deserialization
    def self.deserialization_expectation
      "[Friend Name]"
    end

    # @param name [String] the name of the friend
    def initialize(name:)
      @name = name
    end

    attr_accessor :name

    # @return [String] the file serialization text for the friend
    def serialize
      "#{SERIALIZATION_PREFIX}#{name}"
    end

    private

    # Default sorting for an array of friends is alphabetical.
    def <=>(other)
      name <=> other.name
    end
  end
end
