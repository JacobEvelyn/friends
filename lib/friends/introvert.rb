# Introvert is the internal handler for the friends script. It is designed to be
# able to be used directly within another Ruby program, without needing to call
# the command-line script explicitly.

require "readline"

require "friends/activity"
require "friends/friend"
require "friends/friends_error"

module Friends
  class Introvert
    DEFAULT_FILENAME = "./friends.md"
    ACTIVITIES_HEADER = "### Activities:"
    FRIENDS_HEADER = "### Friends:"
    GRAPH_DATE_FORMAT = "%b %Y" # Used as the param for date.strftime().

    # @param filename [String] the name of the friends Markdown file
    def initialize(filename: DEFAULT_FILENAME)
      @filename = filename
      @cleaned_file = false # Switches to true when the file is cleaned.

      # Read in the input file. It's easier to do this now and optimize later
      # than try to overly be clever about what we read and write.
      read_file
    end

    # Write out the friends file with cleaned/sorted data.
    def clean
      # Short-circuit if we've already cleaned the file so we don't write it
      # twice.
      return @filename if @cleaned_file

      descriptions = @activities.sort.map(&:serialize)
      names = @friends.sort.map(&:serialize)

      # Write out the cleaned file.
      File.open(@filename, "w") do |file|
        file.puts(ACTIVITIES_HEADER)
        descriptions.each { |desc| file.puts(desc) }
        file.puts # Blank line separating friends from activities.
        file.puts(FRIENDS_HEADER)
        names.each { |name| file.puts(name) }
      end

      @cleaned_file = true

      @filename
    end

    # Add a friend and write out the new friends file.
    # @param name [String] the name of the friend to add
    # @raise [FriendsError] when a friend with that name is already in the file
    # @return [Friend] the added friend
    def add_friend(name:)
      if friend_with_exact_name(name)
        raise FriendsError, "Friend named #{name} already exists"
      end

      begin
        friend = Friend.deserialize(name)
      rescue Serializable::SerializationError => e
        raise FriendsError, e
      end

      @friends << friend
      clean # Write a cleaned file.

      friend # Return the added friend.
    end

    # Add an activity and write out the new friends file.
    # @param serialization [String] the serialized activity
    # @return [Activity] the added activity
    def add_activity(serialization:)
      begin
        activity = Activity.deserialize(serialization)
      rescue Serializable::SerializationError => e
        raise FriendsError, e
      end

      # If there's no description, prompt the user for one.
      activity.description ||= Readline.readline(activity.display_text)

      activity.highlight_friends(introvert: self)
      @activities.unshift(activity)
      clean # Write a cleaned file.

      activity # Return the added activity.
    end

    # Add a nickname to an existing friend and write out the new friends file.
    # @param name [String] the name of the friend
    # @param nickname [String] the nickname to add to the friend
    # @raise [FriendsError] if 0 of 2+ friends match the given name
    # @return [Friend] the existing friend
    def add_nickname(name:, nickname:)
      friend = friend_with_name_in(name)
      friend.add_nickname(nickname.strip)

      clean # Write a cleaned file.

      friend
    end

    # Remove a nickname from an existing friend and write out the new friends
    #   file.
    # @param name [String] the name of the friend
    # @param nickname [String] the nickname to remove from the friend
    # @raise [FriendsError] if 0 of 2+ friends match the given name
    # @return [Friend] the existing friend
    def remove_nickname(name:, nickname:)
      friend = friend_with_name_in(name)
      friend.remove_nickname(nickname.strip)

      clean # Write a cleaned file.

      friend
    end

    # List all friend names in the friends file.
    # @return [Array] a list of all friend names
    def list_friends
      @friends.map(&:name)
    end

    # List your favorite friends.
    # @param limit [Integer] the number of favorite friends to return, or nil
    #   for no limit
    # @return [Array] a list of the favorite friends' names and activity
    #   counts
    def list_favorites(limit:)
      if !limit.nil? && limit < 1
        raise FriendsError, "Favorites limit must be positive or unlimited"
      end

      set_n_activities! # Set n_activities for all friends.

      # Sort the results, with the most favorite friend first.
      results = @friends.sort_by { |friend| -friend.n_activities }

      # If we need to, trim the list.
      results = results.take(limit) unless limit.nil?

      max_str_size = results.map(&:name).map(&:size).max
      results.map.with_index(0) do |friend, index|
        name = friend.name.ljust(max_str_size)
        parenthetical = "(#{friend.n_activities}#{' activities' if index == 0})"
        "#{name} #{parenthetical}"
      end
    end

    # List all activity details.
    # @param limit [Integer] the number of activities to return, or nil for no
    #   limit
    # @param with [String] the name of a friend to filter by, or nil for
    #   unfiltered
    # @return [Array] a list of all activity text values
    # @raise [FriendsError] if 0 of 2+ friends match the given `with` text
    def list_activities(limit:, with:)
      acts = @activities

      # Filter by friend name if argument is passed.
      unless with.nil?
        friend = friend_with_name_in(with)
        acts = acts.select { |act| act.includes_friend?(friend: friend) }
      end

      # If we need to, trim the list.
      acts = acts.take(limit) unless limit.nil?

      acts.map(&:display_text)
    end

    # Find data points for graphing a given friend's relationship over time.
    # @param name [String] the name of the friend to use
    # @return [Hash] with the following format:
    #   {
    #     "Jan 2015" => 3,  # The month and number of activities with that
    #     "Feb 2015" => 0, # friend during that month.
    #     "Mar 2015" => 9
    #   }
    #   The keys of the hash are all of the months (inclusive) between the first
    #   and last month in which activities for the given friend have been
    #   recorded.
    # @raise [FriendsError] if 0 of 2+ friends match the given name
    def graph(name:)
      friend = friend_with_name_in(name) # Find the friend by name.

      # Filter out activities that don't include the given friend.
      acts = @activities.select { |act| act.includes_friend?(friend: friend) }

      # Initialize the table of activities to have all of the months of that
      # friend's activity range (including months in the middle of the range
      # with no relevant activities).
      act_table = {}
      (acts.last.date..acts.first.date).each do |date|
        act_table[date.strftime(GRAPH_DATE_FORMAT)] = 0
      end

      acts.each do |activity|
        month = activity.date.strftime(GRAPH_DATE_FORMAT)
        act_table[month] += 1
      end
      act_table
    end

    # @return [Hash] of the format:
    #   {
    #     distant: ["Distant Friend 1 Name", "Distant Friend 2 Name", ...],
    #     moderate: ["Moderate Friend 1 Name", "Moderate Friend 2 Name", ...],
    #     close: ["Close Friend 1 Name", "Close Friend 2 Name", ...]
    #   }
    def suggest
      set_n_activities! # Set n_activities for all friends.

      # Sort our friends, with the least favorite friend first.
      sorted_friends = @friends.sort_by(&:n_activities)

      output = Hash.new { |h, k| h[k] = [] }

      # Set initial value in case there are no friends and the while loop is
      # never entered.
      output[:distant] = []

      # First, get not-so-good friends.
      while !sorted_friends.empty? && sorted_friends.first.n_activities < 2
        output[:distant] << sorted_friends.shift.name
      end

      output[:moderate] = sorted_friends.slice!(0, sorted_friends.size * 3 / 4).
                          map!(&:name)
      output[:close] = sorted_friends.map!(&:name)

      output
    end

    ###################################################################
    # Methods below this are only used internally and are not tested. #
    ###################################################################

    # Sets the n_activities field on each friend.
    def set_n_activities!
      # Construct a hash of friend name to frequency of appearance.
      freq_table = Hash.new { |h, k| h[k] = 0 }
      @activities.each do |activity|
        activity.friend_names.each do |friend_name|
          freq_table[friend_name] += 1
        end
      end

      # Remove names that are not in the friends list.
      freq_table.each do |name, count|
        friend = friend_with_exact_name(name)
        friend.n_activities = count if friend # Do nothing if name not valid.
      end
    end

    # @return [Hash] mapping each friend to a list of all possible regexes for
    #   that friend's name
    def friend_regex_map
      @friends.each_with_object({}) do |friend, hash|
        hash[friend] = friend.regexes_for_name
      end
    end

    # Sets the likelihood_score field on each friend in `possible_matches`. This
    # score represents how likely it is that an activity containing the friends
    # in `matches` and containing a friend from each group in `possible_matches`
    # contains that given friend.
    # @param matches [Array<Friend>] the friends in a specific activity
    # @param possible_matches [Array<Array<Friend>>] an array of groups of
    #   possible matches, for example:
    #   [
    #     [Friend.new(name: "John Doe"), Friend.new(name: "John Deere")],
    #     [Friend.new(name: "Aunt Mae"), Friend.new(name: "Aunt Sue")]
    #   ]
    #   These groups will all contain friends with similar names; the purpose of
    #   this method is to give us a likelihood that a "John" in an activity
    #   description, for instance, is "John Deere" vs. "John Doe"
    def set_likelihood_score!(matches:, possible_matches:)
      combinations = (matches + possible_matches.flatten).
        combination(2).
        reject do |friend1, friend2|
          (matches & [friend1, friend2]).size == 2 ||
          possible_matches.any? do |group|
            (group & [friend1, friend2]).size == 2
          end
        end

      @activities.each do |activity|
        names = activity.friend_names

        combinations.each do |group|
          if (names & group.map(&:name)).size == 2
            group.each { |friend| friend.likelihood_score += 1 }
          end
        end
      end
    end

    private

    # Process the friends.md file and store its contents in internal data
    # structures.
    def read_file
      @friends = []
      @activities = []

      return unless File.exist?(@filename)

      state = :initial
      line_num = 0

      # Loop through all lines in the file and process them.
      File.foreach(@filename) do |line|
        line_num += 1
        line.chomp! # Remove trailing newline from each line.

        case state
        when :initial
          bad_line(ACTIVITIES_HEADER, line_num) unless line == ACTIVITIES_HEADER

          state = :reading_activities
        when :reading_friends
          begin
            @friends << Friend.deserialize(line)
          rescue FriendsError => e
            bad_line(e, line_num)
          end
        when :done_reading_activities
          state = :reading_friends if line == FRIENDS_HEADER
        when :reading_activities
          if line == ""
            state = :done_reading_activities
          else
            begin
              @activities << Activity.deserialize(line)
            rescue FriendsError => e
              bad_line(e, line_num)
            end
          end
        end
      end
    end

    # @param name [String] the name of the friend to search for
    # @return [Friend] the friend whose name exactly matches the argument
    # @raise [FriendsError] if more than one friend has the given name
    def friend_with_exact_name(name)
      results = @friends.select { |friend| friend.name == name }

      case results.size
      when 0 then nil
      when 1 then results.first
      else raise FriendsError, "More than one friend named #{name}"
      end
    end

    # @param text [String] the name (or substring) of the friend to search for
    # @return [Friend] the friend that matches
    # @raise [FriendsError] if 0 of 2+ friends match the given text
    def friend_with_name_in(text)
      friends = friends_with_name_in(text)

      case friends.size
      when 1
        # If exactly one friend matches, use that friend.
        return friends.first
      when 0 then raise FriendsError, "No friend found for \"#{text}\""
      else
        raise FriendsError,
              "More than one friend found for \"#{text}\": "\
                "#{friends.map(&:name).join(', ')}"
      end
    end

    # @param text [String] the name (or substring) of the friends to search for
    # @return [Array] a list of all friends that match the given text
    def friends_with_name_in(text)
      regex = Regexp.new(text, Regexp::IGNORECASE)
      @friends.select { |friend| friend.name.match(regex) }
    end

    # Raise an error that a line in the friends file is malformed.
    # @param expected [String] the expected contents of the line
    # @param line_num [Integer] the line number
    # @raise [FriendsError] with a constructed message
    def bad_line(expected, line_num)
      raise FriendsError, "Expected \"#{expected}\" on line #{line_num}"
    end
  end
end
