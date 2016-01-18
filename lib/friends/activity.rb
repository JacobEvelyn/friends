# frozen_string_literal: true
# Activity represents an activity you've done with one or more Friends.

require "memoist"
require "paint"

require "friends/serializable"

module Friends
  class Activity
    extend Serializable
    extend Memoist

    SERIALIZATION_PREFIX = "- ".freeze

    # @return [Regexp] the regex for capturing groups in deserialization
    def self.deserialization_regex
      # Note: this regex must be on one line because whitespace is important
      # rubocop:disable Metrics/LineLength
      /(#{SERIALIZATION_PREFIX})?((?<date_s>\d{4}-\d\d-\d\d)(:\s)?)?(?<description>.+)?/
      # rubocop:enable Metrics/LineLength
    end

    # @return [Regexp] the string of what we expected during deserialization
    def self.deserialization_expectation
      "[YYYY-MM-DD]: [Activity]"
    end

    # @param date_s [String] the activity's date, parsed using Date.parse()
    # @param description [String] the activity's description
    # @return [Activity] the new activity
    def initialize(date_s: Date.today.to_s, description: nil)
      @date = Date.parse(date_s)
      @description = description
    end

    attr_reader :date
    attr_accessor :description

    # @return [String] the command-line display text for the activity
    def display_text
      date_s = Paint[date, :bold]
      description_s = description.to_s
      while match = description_s.match(/(\*\*)([^\*]+)(\*\*)/)
        description_s = "#{match.pre_match}"\
                        "#{Paint[match[2], :bold, :magenta]}"\
                        "#{match.post_match}"
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
    # @param introvert [Introvert] used to access the list of friends and the
    #  connections between the
    # NOTE: When a friend name matches more than one friend, this method chooses
    # a friend based on a best-guess algorithm that looks at which friends do
    # activities together and which friends are stronger than others. For
    # more information see the comments below and the
    # introvert#set_likelihood_score! method.
    def highlight_friends(introvert:)
      friend_regexes = introvert.friend_regex_map

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

      matched_friends = []

      # First, we find all of the regex matches with only one possibility, and
      # make those substitutions.
      regex_map.
        select { |_, arr| arr.size == 1 }.each do |regex, friend_list|
        if @description.match(regex)
          friend = friend_list.first # There's only one friend in the list.
          matched_friends << friend
          @description.gsub!(regex, "**#{friend.name}**")
        end
      end

      possible_matched_friends = []

      # Now, we look at regex matches that are ambiguous.
      regex_map.
        reject { |_, arr| arr.size == 1 }.each do |regex, friend_list|
        if @description.match(regex)
          possible_matched_friends << friend_list
        end
      end

      # Now, we compute the likelihood of each friend in the possible-match set.
      introvert.set_n_activities!
      introvert.set_likelihood_score!(
        matches: matched_friends,
        possible_matches: possible_matched_friends
      )

      # Now we go through and replace all of the ambiguous matches with our best
      # guess.
      regex_map.
        reject { |_, arr| arr.size == 1 }.each do |regex, friend_list|
        if @description.match(regex)
          guessed_friend = friend_list.sort_by do |friend|
            [-friend.likelihood_score, -friend.n_activities]
          end.first
          @description.gsub!(regex, "**#{guessed_friend.name}**")
        end
      end

      # Lastly, we remove any backslashes, as these are used to escape friends'
      # names that we don't want to match.
      @description.delete!("\\")
    end

    # Updates a friend's old_name to their new_name
    # @param [String] old_name
    # @param [String] new_name
    # @return [String] if name found in description
    # @return [nil] if no change was made
    def update_name(old_name:, new_name:)
      description.gsub!(
        Regexp.new("(?<=\\*\\*)#{old_name}(?=\\*\\*)"),
        new_name)
    end

    # @param friend [Friend] the friend to test
    # @return [Boolean] true iff this activity includes the given friend
    def includes_friend?(friend:)
      friend_names.include? friend.name
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
  end
end
