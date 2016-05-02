# frozen_string_literal: true
# Friend represents a friend. You know, a real-life friend!

require "friends/regex_builder"
require "friends/serializable"

module Friends
  class Friend
    extend Serializable

    SERIALIZATION_PREFIX = "- ".freeze
    NICKNAME_PREFIX = "a.k.a. ".freeze

    # @return [Regexp] the regex for capturing groups in deserialization
    def self.deserialization_regex
      # Note: this regex must be on one line because whitespace is important
      # rubocop:disable Metrics/LineLength
      /(#{SERIALIZATION_PREFIX})?(?<name>[^\(\[]+)(\((?<nickname_str>#{NICKNAME_PREFIX}.+)\))?\s?(\[(?<location_name>[^\]]+)\])?/
      # rubocop:enable Metrics/LineLength
    end

    # @return [Regexp] the string of what we expected during deserialization
    def self.deserialization_expectation
      "[Friend Name]"
    end

    # @param name [String] the name of the friend
    def initialize(name:, nickname_str: nil, location_name: nil)
      @name = name.strip
      @nicknames = nickname_str &&
                   nickname_str.split(NICKNAME_PREFIX)[1..-1].map(&:strip) ||
                   []
      @location_name = location_name
    end

    attr_accessor :name
    attr_accessor :location_name

    # @return [String] the file serialization text for the friend
    def serialize
      "#{SERIALIZATION_PREFIX}#{self}"
    end

    # @return [String] a string representing the friend's name and nicknames
    def to_s
      unless @nicknames.empty?
        nickname_str =
          " (" +
          @nicknames.map { |n| "#{NICKNAME_PREFIX}#{n}" }.join(" ") +
          ")"
      end

      location_str = " [#{@location_name}]" unless @location_name.nil?

      "#{@name}#{nickname_str}#{location_str}"
    end

    # Adds a nickname, avoiding duplicates and stripping surrounding whitespace.
    # @param nickname [String] the nickname to add
    def add_nickname(nickname)
      @nicknames << nickname
      @nicknames.uniq!
    end

    # @param nickname [String] the nickname to remove
    # @return [Boolean] true if the nickname was present, false otherwise
    def remove_nickname(nickname)
      unless @nicknames.include? nickname
        raise FriendsError, "Nickname \"#{nickname}\" not found for \"#{name}\""
      end

      @nicknames.delete(nickname)
    end

    # The number of activities this friend is in. This is for internal use only
    # and is set by the Introvert as needed.
    attr_writer :n_activities
    def n_activities
      @n_activities || 0
    end

    # The likelihood_score that an activity description that matches part of
    # this friend's name does in fact refer to this friend. A higher
    # likelihood_score means it is more likely to be this friend. For more
    # information see the activity#highlight_friends and
    # introvert#set_likelihood_score! methods.
    attr_writer :likelihood_score
    def likelihood_score
      @likelihood_score || 0
    end

    # @return [Array] a list of all regexes to match the name in a string
    #   Example: [
    #     /Jacob\s+Morris\s+Evelyn/,
    #     /Jacob/
    #   ]
    # NOTE: For now we only match on full names or first names.
    def regexes_for_name
      # We generously allow any amount of whitespace between parts of a name.
      splitter = "\\s+"

      # Create the list of regexes and return it.
      chunks = name.split(Regexp.new(splitter))

      # We check nicknames before first names because nicknames may contain
      # first names, as in "Amazing Grace" being a nickname for Grace Hopper.
      [
        chunks,
        *@nicknames.map { |n| [n] },

        # Match a first name followed by a last name initial, period, and then
        # (via lookahead) spacing followed by a lowercase letter. This matches
        # the "Jake E." part of something like "Jake E. and I went skiing." This
        # allows us to correctly count the period as part of the name when it's
        # in the middle of a sentence.
        [chunks.first, "#{chunks.last[0]}\.(?=#{splitter}(?-i)[a-z])"],

        # If the above doesn't match, we check for just the first name and then
        # a last name initial. This matches the "Jake E" part of something like
        # "I went skiing with Jake E." This allows us to correctly exclude the
        # period from the name when it's at the end of a sentence.
        [chunks.first, chunks.last[0]],

        [chunks.first]
      ].map do |words|
        Friends::RegexBuilder.regex(words.join(splitter))
      end
    end

    private

    # Default sorting for an array of friends is alphabetical.
    def <=>(other)
      name <=> other.name
    end
  end
end
