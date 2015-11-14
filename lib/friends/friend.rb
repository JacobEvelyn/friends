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

    # @return [Array] a list of all regexes to match the name in a string, with
    #   longer regexes first
    #   Note: for now we only match on full names or first names
    #   Example: [
    #     /Jacob\s+Morris\s+Evelyn/,
    #     /Jacob/
    #   ]
    def regexes_for_name
      # We generously allow any amount of whitespace between parts of a name.
      splitter = "\\s+"

      # We don't want to match names that are "escaped" with a leading
      # backslash.
      no_leading_backslash = "(?<!\\\\)"

      # We don't want to match names that are directly touching double asterisks
      # as these are treated as sacred by our program.
      no_leading_asterisks = "(?<!\\*\\*)"
      no_ending_asterisks = "(?!\\*\\*)"

      # We don't want to match names that are part of other words.
      no_leading_alphabeticals = "(?<![A-z])"
      no_ending_alphabeticals = "(?![A-z])"

      # Create the list of regexes and return it.
      chunks = name.split(Regexp.new(splitter))

      [chunks, [chunks.first]].map do |words|
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
