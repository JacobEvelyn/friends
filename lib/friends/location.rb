# frozen_string_literal: true
# Location represents a location in the world.

require "friends/regex_builder"
require "friends/serializable"

module Friends
  class Location
    extend Serializable

    SERIALIZATION_PREFIX = "- ".freeze

    # @return [Regexp] the regex for capturing groups in deserialization
    def self.deserialization_regex
      # Note: this regex must be on one line because whitespace is important
      /(#{SERIALIZATION_PREFIX})?(?<name>.+)/
    end

    # @return [Regexp] the string of what we expected during deserialization
    def self.deserialization_expectation
      "[Location Name]"
    end

    # @param name [String] the name of the location
    def initialize(name:)
      @name = name
    end

    attr_accessor :name

    # @return [String] the file serialization text for the location
    def serialize
      "#{SERIALIZATION_PREFIX}#{@name}"
    end

    # @return [Regexp] the regex used to match this location's name in an
    #   activity description
    def regex_for_name
      Friends::RegexBuilder.regex(@name)
    end

    # The number of activities this location is in. This is for internal use
    # only and is set by the Introvert as needed.
    attr_writer :n_activities
    def n_activities
      @n_activities || 0
    end

    private

    # Default sorting for an array of locations is alphabetical.
    def <=>(other)
      name <=> other.name
    end
  end
end
