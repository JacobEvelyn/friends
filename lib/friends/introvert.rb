# frozen_string_literal: true

# Introvert is the internal handler for the friends script. It is designed to be
# able to be used directly within another Ruby program, without needing to call
# the command-line script explicitly.

require "friends/activity"
require "friends/friend"
require "friends/graph"
require "friends/location"
require "friends/friends_error"

module Friends
  class Introvert
    DEFAULT_FILENAME = "./friends.md"
    ACTIVITIES_HEADER = "### Activities:"
    FRIENDS_HEADER = "### Friends:"
    LOCATIONS_HEADER = "### Locations:"

    # @param filename [String] the name of the friends Markdown file
    def initialize(filename: DEFAULT_FILENAME)
      @filename = filename

      # Read in the input file. It's easier to do this now and optimize later
      # than try to overly be clever about what we read and write.
      read_file
    end

    # Write out the friends file with cleaned/sorted data.
    def clean
      File.open(@filename, "w") do |file|
        file.puts(ACTIVITIES_HEADER)
        @activities.sort.each { |act| file.puts(act.serialize) }
        file.puts # Blank line separating activities from friends.
        file.puts(FRIENDS_HEADER)
        @friends.sort.each { |friend| file.puts(friend.serialize) }
        file.puts # Blank line separating friends from locations.
        file.puts(LOCATIONS_HEADER)
        @locations.sort.each { |location| file.puts(location.serialize) }
      end

      @filename
    end

    # Add a friend.
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

      friend # Return the added friend.
    end

    # Add an activity.
    # @param serialization [String] the serialized activity
    # @return [Activity] the added activity
    def add_activity(serialization:)
      begin
        activity = Activity.deserialize(serialization)
      rescue Serializable::SerializationError => e
        raise FriendsError, e
      end

      activity.highlight_description(introvert: self) if activity.description
      @activities.unshift(activity)

      activity # Return the added activity.
    end

    # Add a location.
    # @param name [String] the serialized location
    # @return [Location] the added location
    # @raise [FriendsError] if a location with that name already exists
    def add_location(name:)
      if @locations.any? { |location| location.name == name }
        raise FriendsError, "Location \"#{name}\" already exists"
      end

      begin
        location = Location.deserialize(name)
      rescue Serializable::SerializationError => e
        raise FriendsError, e
      end

      @locations << location

      location # Return the added location.
    end

    # Set a friend's location.
    # @param name [String] the friend's name
    # @param location_name [String] the name of an existing location
    # @raise [FriendsError] if 0 or 2+ friends match the given name
    # @raise [FriendsError] if 0 or 2+ locations match the given location name
    # @return [Friend] the modified friend
    def set_location(name:, location_name:)
      friend = friend_with_name_in(name)
      location = location_with_name_in(location_name)
      friend.location_name = location.name
      friend
    end

    # Rename an existing friend.
    # @param old_name [String] the name of the friend
    # @param new_name [String] the new name of the friend
    # @raise [FriendsError] if 0 or 2+ friends match the given name
    # @return [Friend] the existing friend
    def rename_friend(old_name:, new_name:)
      friend = friend_with_name_in(old_name)
      @activities.each do |activity|
        activity.update_friend_name(old_name: friend.name, new_name: new_name)
      end
      friend.name = new_name
      friend
    end

    # Rename an existing location.
    # @param old_name [String] the name of the location
    # @param new_name [String] the new name of the location
    # @raise [FriendsError] if 0 or 2+ friends match the given name
    # @return [Location] the existing location
    def rename_location(old_name:, new_name:)
      loc = location_with_name_in(old_name)

      # Update locations in activities.
      @activities.each do |activity|
        activity.update_location_name(old_name: loc.name, new_name: new_name)
      end

      # Update locations of friends.
      @friends.select { |f| f.location_name == loc.name }.each do |friend|
        friend.location_name = new_name
      end

      loc.name = new_name # Update location itself.
      loc
    end

    # Add a nickname to an existing friend.
    # @param name [String] the name of the friend
    # @param nickname [String] the nickname to add to the friend
    # @raise [FriendsError] if 0 or 2+ friends match the given name
    # @return [Friend] the existing friend
    def add_nickname(name:, nickname:)
      friend = friend_with_name_in(name)
      friend.add_nickname(nickname)
      friend
    end

    # Add a tag to an existing friend.
    # @param name [String] the name of the friend
    # @param tag [String] the tag to add to the friend, of the form: "@tag"
    # @raise [FriendsError] if 0 or 2+ friends match the given name
    # @return [Friend] the existing friend
    def add_tag(name:, tag:)
      friend = friend_with_name_in(name)
      friend.add_tag(tag)
      friend
    end

    # Remove a tag from an existing friend.
    # @param name [String] the name of the friend
    # @param tag [String] the tag to remove from the friend, of the form: "@tag"
    # @raise [FriendsError] if 0 or 2+ friends match the given name
    # @raise [FriendsError] if the friend does not have the given nickname
    # @return [Friend] the existing friend
    def remove_tag(name:, tag:)
      friend = friend_with_name_in(name)
      friend.remove_tag(tag)
      friend
    end

    # Remove a nickname from an existing friend.
    # @param name [String] the name of the friend
    # @param nickname [String] the nickname to remove from the friend
    # @raise [FriendsError] if 0 or 2+ friends match the given name
    # @raise [FriendsError] if the friend does not have the given nickname
    # @return [Friend] the existing friend
    def remove_nickname(name:, nickname:)
      friend = friend_with_name_in(name)
      friend.remove_nickname(nickname)
      friend
    end

    # List all friend names in the friends file.
    # @param location_name [String] the name of a location to filter by, or nil
    #   for unfiltered
    # @param tagged [String] the name of a tag to filter by (of the form:
    #   "@tag"), or nil for unfiltered
    # @param verbose [Boolean] true iff we should output friend names with
    #   nicknames, locations, and tags; false for names only
    # @return [Array] a list of all friend names
    def list_friends(location_name:, tagged:, verbose:)
      fs = @friends

      # Filter by location if a name is passed.
      if location_name
        location = location_with_name_in(location_name)
        fs = fs.select { |friend| friend.location_name == location.name }
      end

      # Filter by tag if one is passed.
      fs = fs.select { |friend| friend.tags.include? tagged } if tagged

      verbose ? fs.map(&:to_s) : fs.map(&:name)
    end

    # List your favorite friends.
    # @param limit [Integer] the number of favorite friends to return
    # @return [Array] a list of the favorite friends' names and activity
    #   counts
    def list_favorite_friends(limit:)
      list_favorite_things(:friend, limit: limit)
    end

    # List your favorite friends.
    # @param limit [Integer] the number of favorite locations to return
    # @return [Array] a list of the favorite locations' names and activity
    #   counts
    def list_favorite_locations(limit:)
      list_favorite_things(:location, limit: limit)
    end

    # List all activity details.
    # @param limit [Integer] the number of activities to return, or nil for no
    #   limit
    # @param with [String] the name of a friend to filter by, or nil for
    #   unfiltered
    # @param location_name [String] the name of a location to filter by, or nil
    #   for unfiltered
    # @param tagged [String] the name of a tag to filter by (of the form:
    #   "@tag"), or nil for unfiltered
    # @return [Array] a list of all activity text values
    # @raise [FriendsError] if friend, location or tag cannot be found or
    #   is ambiguous
    def list_activities(limit:, with:, location_name:, tagged:)
      acts = filtered_activities(
        with: with,
        location_name: location_name,
        tagged: tagged
      )

      # If we need to, trim the list.
      acts = acts.take(limit) unless limit.nil?

      acts.map(&:to_s)
    end

    # List all location names in the friends file.
    # @return [Array] a list of all location names
    def list_locations
      @locations.map(&:name)
    end

    # @param from [String] one of: ["activities", "friends", nil]
    #   If not nil, limits the tags returned to only those from either
    #   activities or friends.
    # @return [Array] a sorted list of all tags in activity descriptions
    def list_tags(from:)
      output = Set.new

      unless from == "friends" # If from is "activities" or nil.
        @activities.each_with_object(output) do |activity, set|
          set.merge(activity.tags)
        end
      end

      unless from == "activities" # If from is "friends" or nil.
        @friends.each_with_object(output) do |friend, set|
          set.merge(friend.tags)
        end
      end

      output.sort_by(&:downcase)
    end

    # Find data points for graphing activities over time.
    # Optionally filter by friend, location and tag
    #
    # The returned hash uses the following format:
    #   {
    #     "Jan 2015" => 3, # The number of activities during each month.
    #     "Feb 2015" => 0,
    #     "Mar 2015" => 9
    #   }
    # The keys of the hash are all of the months (inclusive) between the first
    # and last month in which activities have been recorded.
    #
    # @param with [String] the name of a friend to filter by, or nil for
    #   unfiltered
    # @param location_name [String] the name of a location to filter by, or nil
    #   for unfiltered
    # @param tagged [String] the name of a tag to filter by (of the form:
    #   "@tag"), or nil for unfiltered
    # @return [Hash{String => Integer}]
    # @raise [FriendsError] if friend, location or tag cannot be found or
    #   is ambiguous
    def graph(with:, location_name:, tagged:)
      # There is no point trying to graph no activities
      return {} if @activities.empty?

      activities_to_graph = filtered_activities(
        with: with,
        location_name: location_name,
        tagged: tagged
      )

      Graph.new(
        start_date: @activities.last.date,
        end_date: @activities.first.date,
        activities: activities_to_graph
      ).to_h
    end

    # Suggest friends to do something with.
    #
    # The returned hash uses the following format:
    #   {
    #     distant: ["Distant Friend 1 Name", "Distant Friend 2 Name", ...],
    #     moderate: ["Moderate Friend 1 Name", "Moderate Friend 2 Name", ...],
    #     close: ["Close Friend 1 Name", "Close Friend 2 Name", ...]
    #   }
    #
    # @param location_name [String] the name of a location to filter by, or nil
    #   for unfiltered
    # @return [Hash{String => Array<String>}]
    def suggest(location_name:)
      set_friend_n_activities! # Set n_activities for all friends.

      # Filter our friends by location if necessary.
      fs = @friends
      fs = fs.select { |f| f.location_name == location_name } if location_name

      # Sort our friends, with the least favorite friend first.
      sorted_friends = fs.sort_by(&:n_activities)

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
    def set_friend_n_activities!
      set_n_activities!(:friend)
    end

    # Get a regex friend map.
    #
    # The returned hash uses the following format:
    #   {
    #     /regex/ => [list of friends matching regex]
    #   }
    #
    # This hash is sorted (because Ruby's hashes are ordered) by decreasing
    # regex key length, so the key /Jacob Evelyn/ appears before /Jacob/.
    #
    # @return [Hash{Regexp => Array<Friends::Friend>}]
    def regex_friend_map
      @friends.each_with_object(Hash.new { |h, k| h[k] = [] }) do |friend, hash|
        friend.regexes_for_name.each do |regex|
          hash[regex] << friend
        end
      end.sort_by { |k, _| -k.to_s.size }.to_h
    end

    # Get a regex location map.
    #
    # The returned hash uses the following format:
    #   {
    #     /regex/ => [list of friends matching regex]
    #   }
    #
    # This hash is sorted (because Ruby's hashes are ordered) by decreasing
    # regex key length, so the key /Paris, France/ appears before /Paris/.
    #
    # @return [Hash{Regexp => Array<Friends::Location>}]
    def regex_location_map
      @locations.each_with_object({}) do |location, hash|
        hash[location.regex_for_name] = location
      end.sort_by { |k, _| -k.to_s.size }.to_h
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

    # @return [Integer] the total number of friends
    def total_friends
      @friends.size
    end

    # @return [Integer] the total number of activities
    def total_activities
      @activities.size
    end

    # @return [Integer] the number of days elapsed between
    #   the first and last activity
    def elapsed_days
      return 0 if @activities.size < 2
      sorted_activities = @activities.sort
      (sorted_activities.first.date - sorted_activities.last.date).to_i
    end

    private

    # Filter activities by friend, location and tag
    # @param with [String] the name of a friend to filter by, or nil for
    #   unfiltered
    # @param location_name [String] the name of a location to filter by, or nil
    #   for unfiltered
    # @param tagged [String] the name of a tag to filter by, or nil for
    #   unfiltered
    # @return [Array] an array of activities
    # @raise [FriendsError] if friend, location or tag cannot be found or
    #   is ambiguous
    def filtered_activities(with:, location_name:, tagged:)
      acts = @activities

      # Filter by friend name if argument is passed.
      unless with.nil?
        friend = friend_with_name_in(with)
        acts = acts.select { |act| act.includes_friend?(friend) }
      end

      # Filter by location name if argument is passed.
      unless location_name.nil?
        location = location_with_name_in(location_name)
        acts = acts.select { |act| act.includes_location?(location) }
      end

      # Filter by tag if argument is passed.
      unless tagged.nil?
        acts = acts.select { |act| act.includes_tag?(tagged) }
      end

      acts
    end

    # @param type [Symbol] one of: [:friend, :location]
    # @param limit [Integer] the number of favorite things to return
    # @return [Array] a list of the favorite things' names and activity counts
    def list_favorite_things(type, limit:)
      unless [:friend, :location].include? type
        raise FriendsError, "Type must be either :friend or :location"
      end

      if limit < 1
        raise FriendsError, "Favorites limit must be positive"
      end

      send("set_n_activities!", type) # Set n_activities for all things.

      # Sort the results, with the most favorite thing first.
      results = instance_variable_get("@#{type}s").sort_by do |thing|
        -thing.n_activities
      end.take(limit) # Trim the list.

      max_str_size = results.map(&:name).map(&:size).max
      results.map.with_index(0) do |thing, index|
        name = thing.name.ljust(max_str_size)
        n = thing.n_activities
        if index == 0
          label = n == 1 ? " activity" : " activities"
        end
        parenthetical = "(#{n}#{label})"
        "#{name} #{parenthetical}"
      end
    end

    # Sets the n_activities field on each thing.
    # @param type [Symbol] one of: [:friend, :location]
    def set_n_activities!(type)
      unless [:friend, :location].include? type
        raise FriendsError, "Type must be either :friend or :location"
      end

      # Construct a hash of location name to frequency of appearance.
      freq_table = Hash.new { |h, k| h[k] = 0 }
      @activities.each do |activity|
        activity.send("#{type}_names").each do |thing_name|
          freq_table[thing_name] += 1
        end
      end

      # Remove names that are not in the locations list.
      freq_table.each do |name, count|
        thing = send("#{type}_with_exact_name", name)
        thing.n_activities = count if thing # Do nothing if name isn't valid.
      end
    end

    # Process the friends.md file and store its contents in internal data
    # structures.
    def read_file
      @friends = []
      @activities = []
      @locations = []

      return unless File.exist?(@filename)

      state = :unknown

      # Loop through all lines in the file and process them.
      File.foreach(@filename).with_index(1) do |line, line_num|
        line.chomp! # Remove trailing newline from each line.

        # Parse the line and update the parsing state.
        state = parse_line!(line, line_num: line_num, state: state)
      end

      # Migrate old tag format (#tag) into new tag format (@tag). This code will
      # be removed in the 1.0 release.
      unless @friends.any? { |f| f.tags.any? } ||
             @activities.any? { |a| a.tags.any? }
        contents = File.read(@filename)
        File.write(@filename, contents.gsub(/#(\p{Alnum}+)/, "@\\1"))
        read_file
      end
    end

    # Parse the given line, adding to the various internal data structures as
    # necessary.
    # @param line [String]
    # @param line_num [Integer] the 1-indexed file line number we're parsing
    # @param state [Symbol] the state of the parsing, one of:
    #   [:unknown, :reading_activities, :reading_friends, :reading_locations]
    # @return [Symbol] the updated state after parsing the given line
    def parse_line!(line, line_num:, state:)
      return :unknown if line == ""

      # If we're in an unknown state, look for a header to tell us what we're
      # parsing next.
      if state == :unknown
        PARSING_STAGES.each do |stage|
          if line == self.class.const_get("#{stage.id.to_s.upcase}_HEADER")
            return "reading_#{stage.id}".to_sym
          end
        end

        # If we made it here, we couldn't recognize a header.
        bad_line("Couldn't parse line.", line_num)
      end

      # If we made it this far, we're parsing objects in a class.
      stage = PARSING_STAGES.find { |s| state == "reading_#{s.id}".to_sym }

      begin
        instance_variable_get("@#{stage.id}") << stage.klass.deserialize(line)
      rescue FriendsError => e
        bad_line(e, line_num)
      end

      state
    end

    # Used internally by the parse_line! method above to associate stages with
    # the class to create.
    ParsingStage = Struct.new(:id, :klass)
    PARSING_STAGES = [
      ParsingStage.new(:activities, Activity),
      ParsingStage.new(:friends, Friend),
      ParsingStage.new(:locations, Location)
    ].freeze

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
    # @raise [FriendsError] if 0 or 2+ friends match the given text
    def friend_with_name_in(text)
      regex = Regexp.new(text, Regexp::IGNORECASE)
      friends = @friends.select { |friend| friend.name.match(regex) }

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

    # @param name [String] the name of the location to search for
    # @return [Location] the location whose name exactly matches the argument
    # @raise [FriendsError] if more than one location has the given name
    def location_with_exact_name(name)
      results = @locations.select { |location| location.name == name }

      case results.size
      when 0 then nil
      when 1 then results.first
      else raise FriendsError, "More than one location named #{name}"
      end
    end

    # @param text [String] the name (or substring) of the location to search for
    # @return [Location] the location that matches
    # @raise [FriendsError] if 0 or 2+ location match the given text
    def location_with_name_in(text)
      regex = Regexp.new(text, Regexp::IGNORECASE)
      locations = @locations.select { |location| location.name.match(regex) }

      case locations.size
      when 1
        # If exactly one location matches, use that location.
        return locations.first
      when 0 then raise FriendsError, "No location found for \"#{text}\""
      else
        raise FriendsError,
              "More than one location found for \"#{text}\": "\
                "#{locations.map(&:name).join(', ')}"
      end
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
