# frozen_string_literal: true

# Location represents a location in the world.

require "friends/regex_builder"
require "friends/serializable"

module Friends
  class Location
    extend Serializable

    SERIALIZATION_PREFIX = "- "
    # NOTE: nickname is the location alias, but `alias` is a keyword
    NICKNAME_REFIX = "a.k.a. "

    # @return [Regexp] the regex for capturing groups in deserialization
    def self.deserialization_regex
      # Note: this regex must be on one line because whitespace is important
      /(#{SERIALIZATION_PREFIX})?(?<name>[^\(\[@]*[^\(\[@\s])(\s+\(#{NICKNAME_REFIX}(?<nickname_str>.+)\))?/ # rubocop:disable Layout/LineLength
    end

    # @return [Regexp] the string of what we expected during deserialization
    def self.deserialization_expectation
      "[Location Name]"
    end

    # @param name [String] the name of the location
    def initialize(name:, nickname_str: nil)
      @name = name
      @nicknames = nickname_str&.split(" #{NICKNAME_REFIX}") || []
    end

    attr_accessor :name
    attr_reader :nicknames

    # @return [String] the file serialization text for the location
    def serialize
      Paint.unpaint("#{SERIALIZATION_PREFIX}#{self}")
    end

    # @return [String] a string representing the location's name and aliases
    def to_s
      unless @nicknames.empty?
        nickname_str = " (" +
                       @nicknames.map do |nickname|
                         "#{NICKNAME_REFIX}#{Paint[nickname, :bold, :yellow]}"
                       end.join(" ") + ")"
      end

      "#{Paint[@name, :bold]}#{nickname_str}"
    end

    # Add a alias, ignoring duplicates.
    # @param nickname [String] the alias to add
    def add_alias(nickname)
      @nicknames << nickname
      @nicknames.uniq!
    end

    # @param nickname [String] the alias to remove
    # @raise [FriendsError] if the location does not have the given alias
    def remove_alias(nickname)
      unless @nicknames.include? nickname
        raise FriendsError, "Alias \"#{nickname}\" not found for \"#{name}\""
      end

      @nicknames.delete(nickname)
    end

    # @return [Array] a list of all regexes to match the name in a string
    # NOTE: Only full names and aliases
    def regexes_for_name
      # We generously allow any amount of whitespace between parts of a name.
      splitter = "\\s+"

      # Create the list of regexes and return it.
      chunks = name.split(Regexp.new(splitter))

      # First we check aliases
      [
        chunks, # Match a full name with the highest priority
        *@nicknames.map { |n| [n] }

      ].compact.map do |words|
        Friends::RegexBuilder.regex(words.join(splitter))
      end
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
