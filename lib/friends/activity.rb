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
      # rubocop:disable Lint/AssignmentInCondition
      while match = description_s.match(/(\*\*)([^\*]+)(\*\*)/)
        # rubocop:enable Lint/AssignmentInCondition
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
      # Split the regex friend map into two maps: one for names with only one
      # friend match and another for ambiguous names
      definite_map, ambiguous_map =
        introvert.regex_friend_map.partition { |_, arr| arr.size == 1 }

      matched_friends = []

      # First, we find all of the unambiguous matches, and make those
      # substitutions.
      definite_map.each do |regex, friend_list|
        # If we find a match, add the friend to the matched list and replace all
        # instances of the matching text with the friend's name.
        description_matches(regex: regex, replace: true) do
          friend = friend_list.first # There's only one friend in the list.
          matched_friends << friend
          friend.name
        end
      end

      possible_matched_friends = []

      # Now, we look at regex matches that are ambiguous.
      ambiguous_map.each do |regex, friend_list|
        # If we find a match, add the friend to the possible-match list.
        description_matches(regex: regex, replace: false) do
          possible_matched_friends << friend_list
        end
      end

      # Now, we compute the likelihood of each friend in the possible-match set.
      introvert.set_n_activities!
      introvert.set_likelihood_score!(
        matches: matched_friends,
        possible_matches: possible_matched_friends
      )

      # Now we replace all of the ambiguous matches with our best guesses.
      ambiguous_map.each do |regex, friend_list|
        # If we find a match, take the most likely and replace all instances of
        # the matching text with that friend's name.
        description_matches(regex: regex, replace: true) do
          friend_list.sort_by do |friend|
            [-friend.likelihood_score, -friend.n_activities]
          end.first.name
        end
      end

      # Lastly, we remove any backslashes, as these are used to escape friends'
      # names that we don't want to match.
      @description = @description.delete("\\")
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

    # This method accepts a block, and tests a regex on the @description
    # instance variable.
    # - If the regex does not match, the block is not executed.
    # - If the regex matches, the block is executed exactly once, and:
    #   - If `replace` is true, all of the regex's matches are replaced by the
    #     return value of the block, EXCEPT when the matched text is between a
    #     set of double-asterisks ("**") indicating it is already part of
    #     another friend's matched name.
    #   - If `replace` is not true, we do not modify @description.
    # @param regex [Regexp] the regex to test against @description
    # @param replace [Boolean] true iff we should replace regex matches with the
    #   yielded block's result in @description
    def description_matches(regex:, replace:)
      # rubocop:disable Lint/AssignmentInCondition
      return unless match = @description.match(regex) # Abort if no match.
      # rubocop:enable Lint/AssignmentInCondition
      str = yield # It's important to execute the block even if not replacing.
      return unless replace # Only continue if we want to replace text.

      position = 0 # Prevent infinite looping by tracking last match position.
      loop do
        # Only make a replacement if we're not between a set of "**"s.
        if match.pre_match.scan("**").size % 2 == 0 &&
           match.post_match.scan("**").size % 2 == 0
          @description = "#{match.pre_match}**#{str}**#{match.post_match}"
        else
          # If we're between double-asterisks we're already part of a name, so
          # we don't make a substitution. We update `position` to avoid infinite
          # looping.
          position = match.end(0)
        end

        # Exit when there are no more matches.
        # rubocop:disable Lint/AssignmentInCondition
        break unless match = @description.match(regex, position)
        # rubocop:enable Lint/AssignmentInCondition
      end
    end

    # Default sorting for an array of activities is reverse-date.
    def <=>(other)
      other.date <=> date
    end
  end
end
