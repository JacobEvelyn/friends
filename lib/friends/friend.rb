# Friend represents a friend. You know, a real-life friend!

module Friends
  class Friend
    SERIALIZATION_PREFIX = "- "

    # @param str [String] the serialized friend string
    # @return [Friend] the friend represented by the serialized string
    def self.deserialize(str)
      match = str.match(/#{SERIALIZATION_PREFIX}(?<name>.+)/)
      unless match && match[:name]
        raise FriendsError, "Expected #{SERIALIZATION_PREFIX}[Friend Name]"
      end

      Friend.new(name: match[:name])
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

    # Default sorting for an array of friends is alphabetical.
    def <=>(other)
      name <=> other.name
    end
  end
end
