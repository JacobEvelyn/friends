# Activity represents an activity you've done with one or more Friends.

require "memoist"

require "friends/serializable"

module Friends
  class Activity
    extend Serializable
    extend Memoist

    SERIALIZATION_PREFIX = "- "

    # @return [Regexp] the regex for capturing groups in deserialization
    def self.deserialization_regex
      /(#{SERIALIZATION_PREFIX})?((?<date_s>\d{4}-\d\d-\d\d):\s)?(?<description>.+)/
    end

    # @return [Regexp] the string of what we expected during deserialization
    def self.deserialization_expectation
      "[YYYY-MM-DD]: [Activity]"
    end

    # @param date_s [String] the activity's date, parsed using Date.parse()
    # @param description [String] the activity's description
    # @return [Activity] the new activity
    def initialize(date_s: Date.today.to_s, description:)
      @date = Date.parse(date_s)
      @description = description
    end

    attr_reader :date
    attr_reader :description

    # @return [String] the command-line display text for the activity
    def display_text
      date_s = "\e[1m#{date}\e[0m"
      description_s = description
      while match = description_s.match(/(\*\*)([^\*]+)(\*\*)/)
        description_s =
          "#{match.pre_match}\e[1m#{match[2]}\e[0m#{match.post_match}"
      end
      "#{date_s}: #{description_s}"
    end

    # @return [String] the file serialization text for the activity
    def serialize
      "#{SERIALIZATION_PREFIX}#{date}: #{description}"
    end

    # Modify the description to turn inputted friend names
    # (e.g. "Jacob" or "Jacob Evelyn") into full asterisk'd names
    # (e.g. "**Jacob Evelyn**")
    # @param introvert [Introvert] for use in aggregate computations
    # @param friends [Array] list of friends to highlight in the description
    # @raise [FriendsError] if more than one friend matches a part of the
    #   description
    def highlight_friends(introvert:, friends:)
      # Map each friend to a list of all possible regexes for that friend.
      friend_regexes = {}
      friends.each { |f| friend_regexes[f] = regexes_for_name(f.name) }

      # Create hash mapping regex to friend. Note that because two friends may
      # have the same regex (e.g. /John/), we need to store the names in an
      # array since there may be more than one. We also iterate through the
      # regexes to add the most important regexes to the hash first, so
      # "Jacob Evelyn" takes precedence over all instances of "Jacob" (since
      # Ruby hashes are ordered).
      regex_map = Hash.new { |h, k| h[k] = [] }
      while !friend_regexes.empty?
        friend_regexes.each do |friend, regex_list|
          regex_map[regex_list.shift] << friend
          friend_regexes.delete(friend) if regex_list.empty?
        end
      end

      # Go through the description and substitute full, asterisk'd names for
      # anything that matches a friend's name.
      new_description = description.clone
      regex_map.each do |regex, friends|
        if friends.size > 1 # If there are multiple matches, find best friend.
          introvert.set_n_activities!
          friends.sort_by! { |friend| -friend.n_activities }
        end

        new_description.gsub!(regex, "**#{friends.first.name}**")
      end

      @description = new_description
    end

    # Find the names of all friends in this description.
    # @return [Array] list of all friend names in the description
    def friend_names
      description.scan(/(?<=\*\*)\w[^\*]*(?=\*\*)/).uniq
    end
    memoize :friend_names

    private

    # Default sorting for an array of activities is reverse-date.
    def <=>(other)
      other.date <=> date
    end

    # @return [Array] a list of all regexes to match the name in a string, with
    #   longer regexes first
    #   Note: for now we only match on full names or first names
    #   Example: [
    #     /Jacob\s+Morris\s+Evelyn/,
    #     /Jacob/
    #   ]
    def regexes_for_name(name)
      # We generously allow any amount of whitespace between parts of a name.
      splitter = "\\s+"

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
          no_leading_asterisks +
          no_leading_alphabeticals +
          words.join(splitter) +
          no_ending_alphabeticals +
          no_ending_asterisks,
          Regexp::IGNORECASE
        )
      end
    end
  end
end
