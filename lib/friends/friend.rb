# frozen_string_literal: true

# Friend represents a friend. You know, a real-life friend!

require "friends/tag_regex"
require "friends/regex_builder"
require "friends/serializable"

module Friends
  class Friend
    extend Serializable

    SERIALIZATION_PREFIX = "- "
    NICKNAME_PREFIX = "a.k.a. "

    # @return [Regexp] the regex for capturing groups in deserialization
    def self.deserialization_regex
      # Note: this regex must be on one line because whitespace is important
      /(#{SERIALIZATION_PREFIX})?(?<name>[^\(\[@]*[^\(\[@\s])(\s+\(#{NICKNAME_PREFIX}(?<nickname_str>.+)\))?(\s+\[(?<location_name>[^\]]+)\])?(\s+(?<tags_str>(#{TAG_REGEX}\s*)+))?/ # rubocop:disable Layout/LineLength
    end

    # @return [Regexp] the string of what we expected during deserialization
    def self.deserialization_expectation
      "[Friend Name]"
    end

    # @param name [String] the name of the friend
    def initialize(
      name:,
      nickname_str: nil,
      location_name: nil,
      tags_str: nil
    )
      @name = name
      @nicknames = nickname_str&.split(" #{NICKNAME_PREFIX}") || []
      @location_name = location_name
      @tags = tags_str&.split(/\s+/) || []
    end

    attr_accessor :name
    attr_accessor :location_name
    attr_reader :tags

    # @return [String] the file serialization text for the friend
    def serialize
      # Remove terminal effects for serialization.
      Paint.unpaint("#{SERIALIZATION_PREFIX}#{self}")
    end

    # @return [String] a string representing the friend's name and nicknames
    def to_s
      unless @nicknames.empty?
        nickname_str = " (" +
                       @nicknames.map do |nickname|
                         "#{NICKNAME_PREFIX}#{Paint[nickname, :bold, :magenta]}"
                       end.join(" ") + ")"
      end

      location_str = " [#{Paint[@location_name, :bold, :yellow]}]" unless @location_name.nil?

      tag_str = " #{Paint[@tags.join(' '), :bold, :cyan]}" unless @tags.empty?

      "#{Paint[@name, :bold]}#{nickname_str}#{location_str}#{tag_str}"
    end

    # Adds a tag, ignoring duplicates.
    # @param tag [String] the tag to add, of the format: "@tag"
    def add_tag(tag)
      @tags << tag
      @tags.uniq!
    end

    # @param tag [String] the tag to remove, of the format: "@tag"
    def remove_tag(tag)
      raise FriendsError, "Tag \"#{tag}\" not found for \"#{name}\"" unless @tags.include? tag

      @tags.delete(tag)
    end

    # Adds a nickname, ignoring duplicates.
    # @param nickname [String] the nickname to add
    def add_nickname(nickname)
      @nicknames << nickname
      @nicknames.uniq!
    end

    # @param nickname [String] the nickname to remove
    # @raise [FriendsError] if the friend does not have the given nickname
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
      defined?(@n_activities) ? @n_activities : 0
    end

    # The likelihood_score that an activity description that matches part of
    # this friend's name does in fact refer to this friend. A higher
    # likelihood_score means it is more likely to be this friend. For more
    # information see the activity#highlight_friends and
    # introvert#set_likelihood_score! methods.
    attr_writer :likelihood_score
    def likelihood_score
      defined?(@likelihood_score) ? @likelihood_score : 0
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
        chunks, # Match a full name with the highest priority.
        *@nicknames.map { |n| [n] },

        # Match a first name followed by a last name initial, period (that via
        # lookahead is *NOT* a part of an ellipsis), and then (via lookahead)
        # either:
        # - other punctuation that would indicate we want to swallow the period
        #   (note that we do not include closing parentheses in this list because
        #   they could be part of an offset sentence), OR
        # - anything, so long as the first alphabetical character afterwards is
        #   lowercase.
        # This matches the "Jake E." part of something like "Jake E. and I went
        # skiing." or "Jake E., Marie Curie, and I studied science." This
        # allows us to correctly count the period as part of the name when it's
        # in the middle of a sentence.
        (
          if chunks.size > 1
            [chunks.first, "#{chunks.last[0]}\\.(?!\\.\\.)(?=([,!?;:—]+|(?-i)[^A-Z]+[a-z]))"]
          end
        ),

        # If the above doesn't match, we check for just the first name and then
        # a last name initial. This matches the "Jake E" part of something like
        # "I went skiing with Jake E." This allows us to correctly exclude the
        # period from the name when it's at the end of a sentence.
        ([chunks.first, chunks.last[0]] if chunks.size > 1),

        *(1..chunks.size - 1).map { |i| chunks.take(i) }.reverse
      ].compact.map do |words|
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
