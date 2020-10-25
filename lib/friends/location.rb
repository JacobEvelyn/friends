# frozen_string_literal: true

# Location represents a location in the world.

require "friends/regex_builder"
require "friends/serializable"

module Friends
  class Location
    extend Serializable

    SERIALIZATION_PREFIX = "- "
    ALIAS_PREFIX = "a.k.a. "

    # @return [Regexp] the regex for capturing groups in deserialization
    def self.deserialization_regex
      # Note: this regex must be on one line because whitespace is important
      /(#{SERIALIZATION_PREFIX})?(?<name>[^\(]*[^\(\s])(\s+\(#{ALIAS_PREFIX}(?<alias_str>.+)\))?/
    end

    # @return [Regexp] the string of what we expected during deserialization
    def self.deserialization_expectation
      "[Location Name]"
    end

    # @param name [String] the name of the location
    def initialize(name:, alias_str: nil)
      @name = name
      @aliases = alias_str&.split(" #{ALIAS_PREFIX}") || []
    end

    attr_accessor :name
    attr_reader :aliases

    # @return [String] the file serialization text for the location
    def serialize
      Paint.unpaint("#{SERIALIZATION_PREFIX}#{self}")
    end

    # @return [String] a string representing the location's name and aliases
    def to_s
      unless @aliases.empty?
        alias_str = " (" +
                    @aliases.map do |nickname|
                      "#{ALIAS_PREFIX}#{Paint[nickname, :bold, :yellow]}"
                    end.join(" ") + ")"
      end

      "#{Paint[@name, :bold]}#{alias_str}"
    end

    # Add an alias, ignoring duplicates.
    # @param nickname [String] the alias to add
    def add_alias(nickname)
      @aliases << nickname
      @aliases.uniq!
    end

    # @param nickname [String] the alias to remove
    # @raise [FriendsError] if the location does not have the given alias
    def remove_alias(nickname)
      unless @aliases.include? nickname
        raise FriendsError, "Alias \"#{nickname}\" not found for \"#{name}\""
      end

      @aliases.delete(nickname)
    end

    # @return [Array] a list of all regexes to match the name in a string
    # NOTE: Only full names and aliases
    def regexes_for_name
      [name, *@aliases].map { |str| Friends::RegexBuilder.regex(str) }
    end

    # The number of activities this location is in. This is for internal use
    # only and is set by the Introvert as needed.
    attr_writer :n_activities
    def n_activities
      defined?(@n_activities) ? @n_activities : 0
    end

    private

    # Default sorting for an array of locations is alphabetical.
    def <=>(other)
      name <=> other.name
    end
  end
end
