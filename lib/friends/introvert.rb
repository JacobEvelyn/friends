# frozen_string_literal: true

# Introvert is the internal handler for the friends script. It is designed to be
# able to be used directly within another Ruby program, without needing to call
# the command-line script explicitly.

require "set"

require "friends/activity"
require "friends/note"
require "friends/friend"
require "friends/graph"
require "friends/location"
require "friends/friends_error"

module Friends
  class Introvert
    ACTIVITIES_HEADER = "### Activities:".freeze
    NOTES_HEADER = "### Notes:".freeze
    FRIENDS_HEADER = "### Friends:".freeze
    LOCATIONS_HEADER = "### Locations:".freeze

    # @param filename [String] the name of the friends Markdown file
    # @param quiet [Boolean] true iff we should suppress all STDOUT output
    def initialize(filename:, quiet:)
      @filename = filename
      @quiet = quiet

      # Read in the input file. It's easier to do this now and optimize later
      # than try to overly be clever about what we read and write.
      read_file
    end

    # Write out the friends file with cleaned/sorted data.
    # @param clean_command [Boolean] true iff the command the user
    #   executed is `friends clean`; false if this is called as the
    #   result of another command
    def clean(clean_command:)
      friend_names = Set.new(@friends.map(&:name))
      location_names = Set.new(@locations.map(&:name))

      # Iterate through all events and add missing friends and
      # locations.
      (@activities + @notes).each do |event|
        event.friend_names.each do |name|
          unless friend_names.include? name
            add_friend(name: name)
            friend_names << name
          end
        end

        event.location_names.each do |name|
          unless location_names.include? name
            add_location(name: name)
            location_names << name
          end
        end
      end

      File.open(@filename, "w") do |file|
        file.puts(ACTIVITIES_HEADER)
        stable_sort(@activities).each { |act| file.puts(act.serialize) }
        file.puts # Blank line separating activities from notes.
        file.puts(NOTES_HEADER)
        stable_sort(@notes).each { |note| file.puts(note.serialize) }
        file.puts # Blank line separating notes from friends.
        file.puts(FRIENDS_HEADER)
        @friends.sort.each { |friend| file.puts(friend.serialize) }
        file.puts # Blank line separating friends from locations.
        file.puts(LOCATIONS_HEADER)
        @locations.sort.each { |location| file.puts(location.serialize) }
      end

      # This is a special-case piece of code that lets us print a message that
      # includes the filename when `friends clean` is called.
      safe_puts "File cleaned: \"#{@filename}\"" if clean_command
    end

    # Add a friend.
    # @param name [String] the name of the friend to add
    # @raise [FriendsError] when a friend with that name is already in the file
    def add_friend(name:)
      if @friends.any? { |friend| friend.name == name }
        raise FriendsError, "Friend named \"#{name}\" already exists"
      end

      friend = Friend.deserialize(name)

      @friends << friend

      safe_puts "Friend added: \"#{friend.name}\""
    end

    # Add an activity.
    # @param serialization [String] the serialized activity
    def add_activity(serialization:)
      Activity.deserialize(serialization).tap do |activity|
        # If there's no description, prompt the user for one.
        if activity.description.nil? || activity.description.empty?
          activity.description = Readline.readline(activity.to_s).to_s.strip

          raise FriendsError, "Blank activity not added" if activity.description.empty?
        end

        activity.highlight_description(introvert: self)

        @activities.unshift(activity)

        safe_puts "Activity added: \"#{activity}\""
      end
    end

    # Add a note.
    # @param serialization [String] the serialized note
    def add_note(serialization:)
      Note.deserialize(serialization).tap do |note|
        # If there's no description, prompt the user for one.
        if note.description.nil? || note.description.empty?
          note.description = Readline.readline(note.to_s).to_s.strip

          raise FriendsError, "Blank note not added" if note.description.empty?
        end

        note.highlight_description(introvert: self)

        @notes.unshift(note)

        safe_puts "Note added: \"#{note}\""
      end
    end

    # Add a location.
    # @param name [String] the serialized location
    # @raise [FriendsError] if a location with that name already exists
    def add_location(name:)
      if @locations.any? { |location| location.name == name }
        raise FriendsError, "Location \"#{name}\" already exists"
      end

      location = Location.deserialize(name)

      @locations << location

      safe_puts "Location added: \"#{location.name}\"" # Return the added location.
    end

    # Set a friend's location.
    # @param name [String] the friend's name
    # @param location_name [String] the name of an existing location
    # @raise [FriendsError] if 0 or 2+ friends match the given name
    # @raise [FriendsError] if 0 or 2+ locations match the given location name
    def set_location(name:, location_name:)
      friend = thing_with_name_in(:friend, name)
      location = thing_with_name_in(:location, location_name)
      friend.location_name = location.name

      safe_puts "#{friend.name}'s location set to: \"#{location.name}\""
    end

    # Rename an existing friend.
    # @param old_name [String] the name of the friend
    # @param new_name [String] the new name of the friend
    # @raise [FriendsError] if 0 or 2+ friends match the given name
    def rename_friend(old_name:, new_name:)
      friend = thing_with_name_in(:friend, old_name)
      (@activities + @notes).each do |event|
        event.update_friend_name(old_name: friend.name, new_name: new_name)
      end
      friend.name = new_name

      safe_puts "Name changed: \"#{friend}\""
    end

    # Rename an existing location.
    # @param old_name [String] the name of the location
    # @param new_name [String] the new name of the location
    # @raise [FriendsError] if 0 or 2+ friends match the given name
    def rename_location(old_name:, new_name:)
      loc = thing_with_name_in(:location, old_name)

      # Update locations in activities and notes.
      (@activities + @notes).each do |event|
        event.update_location_name(old_name: loc.name, new_name: new_name)
      end

      # Update locations of friends.
      @friends.select { |f| f.location_name == loc.name }.each do |friend|
        friend.location_name = new_name
      end

      loc.name = new_name # Update location itself.

      safe_puts "Location renamed: \"#{loc.name}\""
    end

    # Add a nickname to an existing friend.
    # @param name [String] the name of the friend
    # @param nickname [String] the nickname to add to the friend
    # @raise [FriendsError] if 0 or 2+ friends match the given name
    def add_nickname(name:, nickname:)
      raise FriendsError, "Nickname cannot be blank" if nickname.empty?

      friend = thing_with_name_in(:friend, name)
      friend.add_nickname(nickname)

      safe_puts "Nickname added: \"#{friend}\""
    end

    # Add a tag to an existing friend.
    # @param name [String] the name of the friend
    # @param tag [String] the tag to add to the friend, of the form: "@tag"
    # @raise [FriendsError] if 0 or 2+ friends match the given name
    def add_tag(name:, tag:)
      raise FriendsError, "Tag cannot be blank" if tag == "@"

      friend = thing_with_name_in(:friend, name)
      friend.add_tag(tag)

      safe_puts "Tag added to friend: \"#{friend}\""
    end

    # Remove a tag from an existing friend.
    # @param name [String] the name of the friend
    # @param tag [String] the tag to remove from the friend, of the form: "@tag"
    # @raise [FriendsError] if 0 or 2+ friends match the given name
    # @raise [FriendsError] if the friend does not have the given nickname
    def remove_tag(name:, tag:)
      friend = thing_with_name_in(:friend, name)
      friend.remove_tag(tag)

      safe_puts "Tag removed from friend: \"#{friend}\""
    end

    # Remove a nickname from an existing friend.
    # @param name [String] the name of the friend
    # @param nickname [String] the nickname to remove from the friend
    # @raise [FriendsError] if 0 or 2+ friends match the given name
    # @raise [FriendsError] if the friend does not have the given nickname
    def remove_nickname(name:, nickname:)
      friend = thing_with_name_in(:friend, name)
      friend.remove_nickname(nickname)

      safe_puts "Nickname removed: \"#{friend}\""
    end

    # List all friend names in the friends file.
    # @param location_name [String] the name of a location to filter by, or nil
    #   for unfiltered
    # @param tagged [Array<String>] the names of tags to filter by, or empty for
    #   unfiltered
    # @param verbose [Boolean] true iff we should output friend names with
    #   nicknames, locations, and tags; false for names only
    def list_friends(location_name:, tagged:, verbose:)
      fs = @friends

      # Filter by location if a name is passed.
      if location_name
        location = thing_with_name_in(:location, location_name)
        fs = fs.select { |friend| friend.location_name == location.name }
      end

      # Filter by tag if param is passed.
      unless tagged.empty?
        fs = fs.select do |friend|
          tagged.all? { |tag| friend.tags.include? tag }
        end
      end

      safe_puts(verbose ? fs.map(&:to_s) : fs.map(&:name))
    end

    # List your favorite friends.
    # @param limit [Integer] the number of favorite friends to return
    def list_favorite_friends(limit:)
      list_favorite_things(:friend, limit: limit)
    end

    # List your favorite friends.
    # @param limit [Integer] the number of favorite locations to return
    def list_favorite_locations(limit:)
      list_favorite_things(:location, limit: limit)
    end

    # See `list_events` for all of the parameters we can pass.
    def list_activities(**args)
      list_events(events: @activities, **args)
    end

    # See `list_events` for all of the parameters we can pass.
    def list_notes(**args)
      list_events(events: @notes, **args)
    end

    # List all location names in the friends file.
    def list_locations
      safe_puts @locations.map(&:name)
    end

    # @param from [Array] containing any of: ["activities", "friends", "notes"]
    #   If not empty, limits the tags returned to only those from either
    #   activities, notes, or friends.
    def list_tags(from:)
      safe_puts tags(from: from).sort_by(&:downcase)
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
    # @param with [Array<String>] the names of friends to filter by, or empty for
    #   unfiltered
    # @param location_name [String] the name of a location to filter by, or
    #   nil for unfiltered
    # @param tagged [Array<String>] the names of tags to filter by, or empty for
    #   unfiltered
    # @param since_date [Date] a date on or after which to find activities, or nil for unfiltered
    # @param until_date [Date] a date before or on which to find activities, or nil for unfiltered
    # @raise [FriendsError] if friend, location or tag cannot be found or
    #   is ambiguous
    def graph(with:, location_name:, tagged:, since_date:, until_date:)
      filtered_activities_to_graph = filtered_events(
        events: @activities,
        with: with,
        location_name: location_name,
        tagged: tagged,
        since_date: since_date,
        until_date: until_date
      )

      # If the user wants to graph in a specific date range, we explicitly
      # limit our output to that date range. We don't just use the date range
      # of the first and last `filtered_activities_to_graph` because those
      # activities might not include others in the full range (for instance,
      # if only one filtered activity matches a query, we don't want to only
      # show unfiltered activities that occurred on that specific day).
      all_activities_to_graph = filtered_events(
        events: @activities,
        with: [],
        location_name: nil,
        tagged: [],
        since_date: since_date,
        until_date: until_date
      )

      Graph.new(
        filtered_activities: filtered_activities_to_graph,
        all_activities: all_activities_to_graph
      ).draw
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
    def suggest(location_name:)
      # Filter our friends by location if necessary.
      fs = @friends
      fs = fs.select { |f| f.location_name == location_name } if location_name

      # Sort our friends, with the least favorite friend first.
      sorted_friends = fs.sort_by(&:n_activities)

      # Set initial value in case there are no friends and the while loop is
      # never entered.
      distant_friend_names = []

      # First, get not-so-good friends.
      while !sorted_friends.empty? && sorted_friends.first.n_activities < 2
        distant_friend_names << sorted_friends.shift.name
      end

      moderate_friend_names = sorted_friends.slice!(0, sorted_friends.size * 3 / 4).
                              map!(&:name)
      close_friend_names = sorted_friends.map!(&:name)

      safe_puts "Distant friend: "\
                "#{Paint[distant_friend_names.sample || 'None found', :bold, :magenta]}"
      safe_puts "Moderate friend: "\
                "#{Paint[moderate_friend_names.sample || 'None found', :bold, :magenta]}"
      safe_puts "Close friend: "\
                "#{Paint[close_friend_names.sample || 'None found', :bold, :magenta]}"
    end

    ###################################################################
    # Methods below this are only used internally and are not tested. #
    ###################################################################

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

    def stats
      safe_puts "Total activities: #{@activities.size}"
      safe_puts "Total friends: #{@friends.size}"
      safe_puts "Total locations: #{@locations.size}"
      safe_puts "Total notes: #{@notes.size}"
      safe_puts "Total tags: #{tags.size}"

      events = @activities + @notes

      elapsed_days = if events.size < 2
                       0
                     else
                       sorted_events = events.sort
                       (sorted_events.first.date - sorted_events.last.date).to_i
                     end

      safe_puts "Total time elapsed: #{elapsed_days} day#{'s' if elapsed_days != 1}"
    end

    private

    # Print the message unless we're in `quiet` mode.
    # @param str [String] a message to print
    def safe_puts(str)
      puts str unless @quiet
    end

    # @param from [Array] containing any of: ["activities", "friends", "notes"]
    #   If not empty, limits the tags returned to only those from either
    #   activities, notes, or friends.
    # @return [Set] the set of tags present in the given things
    def tags(from: [])
      Set.new.tap do |output|
        if from.empty? || from.include?("activities")
          @activities.each { |activity| output.merge(activity.tags) }
        end

        @notes.each { |note| output.merge(note.tags) } if from.empty? || from.include?("notes")

        if from.empty? || from.include?("friends")
          @friends.each { |friend| output.merge(friend.tags) }
        end
      end
    end

    # List all event details.
    # @param events [Array<Event>] the base events to list, either @activities or @notes
    # @param limit [Integer] the number of events to return, or nil for no
    #   limit
    # @param with [Array<String>] the names of friends to filter by, or empty for
    #   unfiltered
    # @param location_name [String] the name of a location to filter by, or
    #   nil for unfiltered
    # @param tagged [Array<String>] the names of tags to filter by, or empty for
    #   unfiltered
    # @param since_date [Date] a date on or after which to find events, or nil for unfiltered
    # @param until_date [Date] a date before or on which to find events, or nil for unfiltered
    # @raise [ArgumentError] if limit is present but limit < 1
    # @raise [FriendsError] if friend, location or tag cannot be found or
    #   is ambiguous
    def list_events(events:, limit:, with:, location_name:, tagged:, since_date:, until_date:)
      raise ArgumentError, "Limit must be positive" if limit && limit < 1

      events = filtered_events(
        events: events,
        with: with,
        location_name: location_name,
        tagged: tagged,
        since_date: since_date,
        until_date: until_date
      )

      # If we need to, trim the list.
      events = events.take(limit) unless limit.nil?

      safe_puts events.map(&:to_s)
    end

    # @param arr [Array] an unsorted array
    # @return [Array] a stably-sorted array
    def stable_sort(arr)
      arr.sort_by.with_index { |x, idx| [x, idx] }
    end

    # Filter activities by friend, location and tag
    # @param events [Array<Event>] the base events to list, either @activities or @notes
    # @param with [Array<String>] the names of friends to filter by, or empty for
    #   unfiltered
    # @param location_name [String] the name of a location to filter by, or
    #   nil for unfiltered
    # @param tagged [Array<String>] the names of tags to filter by, or empty for
    #   unfiltered
    # @param since_date [Date] a date on or after which to find activities, or nil for unfiltered
    # @param until_date [Date] a date before or on which to find activities, or nil for unfiltered
    # @return [Array] an array of activities or notes
    # @raise [FriendsError] if friend, location or tag cannot be found or
    #   is ambiguous
    def filtered_events(events:, with:, location_name:, tagged:, since_date:, until_date:)
      # Filter by friend name if argument is passed.
      unless with.empty?
        friends = with.map { |name| thing_with_name_in(:friend, name) }
        events = events.select do |event|
          friends.all? { |friend| event.includes_friend?(friend) }
        end
      end

      # Filter by location name if argument is passed.
      unless location_name.nil?
        location = thing_with_name_in(:location, location_name)
        events = events.select { |event| event.includes_location?(location) }
      end

      # Filter by tag if argument is passed.
      unless tagged.empty?
        events = events.select do |event|
          tagged.all? { |tag| event.includes_tag?(tag) }
        end
      end

      # Filter by date if arguments are passed.
      events = events.select { |event| event.date >= since_date } unless since_date.nil?
      events = events.select { |event| event.date <= until_date } unless until_date.nil?

      events
    end

    # @param type [Symbol] one of: [:friend, :location]
    # @param limit [Integer] the number of favorite things to return
    # @raise [ArgumentError] if type is not one of: [:friend, :location]
    # @raise [ArgumentError] if limit is < 1
    def list_favorite_things(type, limit:)
      unless [:friend, :location].include? type
        raise ArgumentError, "Type must be either :friend or :location"
      end

      raise ArgumentError, "Favorites limit must be positive" if limit < 1

      # Sort the results, with the most favorite thing first.
      results = instance_variable_get("@#{type}s").sort_by do |thing|
        -thing.n_activities
      end.take(limit) # Trim the list.

      if results.size == 1
        favorite = results.first
        safe_puts "Your favorite #{type} is "\
                  "#{favorite.name} "\
                  "(#{favorite.n_activities} "\
                  "#{favorite.n_activities == 1 ? 'activity' : 'activities'})"
      else
        safe_puts "Your favorite #{type}s:"

        max_str_size = results.map(&:name).map(&:size).max

        grouped_results = results.group_by(&:n_activities)

        rank = 1
        first = true
        data = grouped_results.each.with_object([]) do |(n_activities, things), arr|
          things.each do |thing|
            name = thing.name.ljust(max_str_size)
            if first
              label = n_activities == 1 ? " activity" : " activities"
              first = false
            end
            str = "#{name} (#{n_activities}#{label})"

            arr << [rank, str]
          end
          rank += things.size
        end

        # We need to use `data.last.first` instead of `rank` to determine the size
        # of the numbering prefix because `rank` will simply be the size of all
        # elements, which may be too large if the last element in the list is a tie.
        num_str_size = data.last.first.to_s.size + 1 unless data.empty?
        data.each do |ranking, str|
          safe_puts "#{"#{ranking}.".ljust(num_str_size)} #{str}"
        end
      end
    end

    # Sets the n_activities field on each thing.
    # @param type [Symbol] one of: [:friend, :location]
    # @raise [ArgumentError] if `type` is not one of: [:friend, :location]
    def set_n_activities!(type)
      unless [:friend, :location].include? type
        raise ArgumentError, "Type must be either :friend or :location"
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
        things = instance_variable_get("@#{type}s").select do |thing|
          thing.name == name
        end

        # Do nothing if no matches found.
        if things.size == 1
          things.first.n_activities = count
        elsif things.size > 1
          raise FriendsError, "More than one #{type} named \"#{name}\""
        end
      end
    end

    # Process the friends.md file and store its contents in internal data
    # structures.
    def read_file
      @friends = []
      @activities = []
      @notes = []
      @locations = []

      return unless File.exist?(@filename)

      state = :unknown

      # Loop through all lines in the file and process them.
      File.foreach(@filename).with_index(1) do |line, line_num|
        line.chomp! # Remove trailing newline from each line.

        # Parse the line and update the parsing state.
        state = parse_line!(line, line_num: line_num, state: state)
      end

      set_n_activities!(:friend)
      set_n_activities!(:location)
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
        bad_line("a valid header", line_num)
      end

      # If we made it this far, we're parsing objects in a class.
      stage = PARSING_STAGES.find { |s| state == "reading_#{s.id}".to_sym }

      begin
        instance_variable_get("@#{stage.id}") << stage.klass.deserialize(line)
      rescue => e # rubocop:disable Style/RescueStandardError
        bad_line(e, line_num)
      end

      state
    end

    # Used internally by the parse_line! method above to associate stages with
    # the class to create.
    ParsingStage = Struct.new(:id, :klass)
    PARSING_STAGES = [
      ParsingStage.new(:activities, Activity),
      ParsingStage.new(:notes, Note),
      ParsingStage.new(:friends, Friend),
      ParsingStage.new(:locations, Location)
    ].freeze

    # @param type [Symbol] one of: [:friend, :location]
    # @param text [String] the name (or substring) of the friend or location to
    #   search for
    # @return [Friend/Location] the friend or location that matches
    # @raise [FriendsError] if 0 or 2+ friends match the given text
    def thing_with_name_in(type, text)
      things = instance_variable_get("@#{type}s").select do |thing|
        if type == :friend
          thing.regexes_for_name.any? { |regex| regex.match(text) }
        else
          thing.regex_for_name.match(text)
        end
      end

      # If there's more than one match with fuzzy regexes but exactly one thing
      # with that exact name, match it.
      if things.size > 1
        exact_things = things.select do |thing|
          thing.name.casecmp(text).zero? # We ignore case for an "exact" match.
        end

        things = exact_things if exact_things.size == 1
      end

      case things.size
      when 1 then things.first # If exactly one thing matches, use that thing.
      when 0 then raise FriendsError, "No #{type} found for \"#{text}\""
      else
        raise FriendsError,
              "More than one #{type} found for \"#{text}\": "\
                "#{things.map(&:name).join(', ')}"
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
