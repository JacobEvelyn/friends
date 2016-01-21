# frozen_string_literal: true
# Friend represents a friend. You know, a real-life friend!

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
      /(#{SERIALIZATION_PREFIX})?(?<name>[^\(]+)(\((?<nickname_str>#{NICKNAME_PREFIX}.+)\))?/
      # rubocop:enable Metrics/LineLength
    end

    # @return [Regexp] the string of what we expected during deserialization
    def self.deserialization_expectation
      "[Friend Name]"
    end

    # @param name [String] the name of the friend
    def initialize(name:, nickname_str: nil)
      @name = name.strip
      @nicknames = nickname_str &&
                   nickname_str.split(NICKNAME_PREFIX)[1..-1].map(&:strip) ||
                   []
    end

    attr_accessor :name

    # @return [String] the file serialization text for the friend
    def serialize
      "#{SERIALIZATION_PREFIX}#{self}"
    end

    # @return [String] a string representing the friend's name and nicknames
    def to_s
      return name if @nicknames.empty?

      nickname_str = @nicknames.map { |n| "#{NICKNAME_PREFIX}#{n}" }.join(" ")
      "#{name} (#{nickname_str})"
    end

    # Adds a nickname, avoiding duplicates and stripping surrounding whitespace.
    # @param nickname [String] the nickname to add
    def add_nickname(nickname)
      @nicknames << nickname
      @nicknames.uniq!
    end

    # Renames a friend, avoiding duplicates and stripping surrounding
    # whitespace.
    # @param new_name [String] the friend's new name
    def rename(new_name)
      @name = new_name
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

      # We don't want to match names that are "escaped" with a leading
      # backslash.
      no_leading_backslash = "(?<!\\\\)"

      # We don't want to match names that are directly touching double asterisks
      # as these are treated as sacred by our program.
      # NOTE: Technically we don't need this check here, since we perform a more
      # complex asterisk check in the Activity#description_matches method, but
      # this class shouldn't need to know about the internal implementation of
      # another class.
      no_leading_asterisks = "(?<!\\*\\*)"
      no_ending_asterisks = "(?!\\*\\*)"

      # We don't want to match names that are part of other words.
      no_leading_alphabeticals = "(?<![A-z])"
      no_ending_alphabeticals = "(?![A-z])"

      # Create the list of regexes and return it.
      chunks = name.split(Regexp.new(splitter))

      [chunks, [chunks.first], *@nicknames.map { |n| [n] }].map do |words|
        Regexp.new(
          no_leading_backslash +
          no_leading_asterisks +
          no_leading_alphabeticals +
          words.join(splitter) +
          no_ending_alphabeticals +
          no_ending_asterisks,
          Regexp::IGNORECASE
        )
      end
    end

    private

    # Default sorting for an array of friends is alphabetical.
    def <=>(other)
      name <=> other.name
    end
  end
end
