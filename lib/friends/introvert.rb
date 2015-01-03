# Introvert is the internal handler for the friends script.

require "friends/activity"
require "friends/friend"
require "friends/friends_error"

module Friends
  class Introvert
    DEFAULT_FILENAME = "./friends.md"
    ACTIVITIES_HEADER = "### Activities:"
    FRIENDS_HEADER = "### Friends:"

    # @param filename [String] the name of the friends Markdown file
    def initialize(filename: DEFAULT_FILENAME)
      @filename = filename
      @cleaned_file = false # Switches to true when the file is cleaned.

      # Read in the input file. It's easier to do this now and optimize later
      # than try to overly be clever about what we read and write.
      read_file(filename: @filename)
    end

    attr_reader :filename
    attr_reader :activities

    # Write out the friends file with cleaned/sorted data.
    def clean
      # Short-circuit if we've already cleaned the file so we don't write it
      # twice.
      return filename if @cleaned_file

      descriptions = activities.sort.map(&:serialize)
      names = friends.sort.map(&:serialize)

      # Write out the cleaned file.
      File.open(filename, "w") do |file|
        file.puts(ACTIVITIES_HEADER)
        descriptions.each { |desc| file.puts(desc) }
        file.puts # Blank line separating friends from activities.
        file.puts(FRIENDS_HEADER)
        names.each { |name| file.puts(name) }
      end

      @cleaned_file = true

      filename
    end

    # List all friend names in the friends file.
    # @return [Array] a list of all friend names
    def list_friends
      friends.map(&:name)
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

      friends << friend
      clean # Write a cleaned file.

      friend # Return the added friend.
    end

    # List all activity details
    # @return [Array] a list of all activity text values
    def list_activities
      activities.map(&:display_text)
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

      activity.highlight_friends(friends: friends)
      activities << activity
      clean # Write a cleaned file.

      activity # Return the added activity.
    end

    private

    # Gets the list of friends as read from the file.
    # @return [Array] a list of all friends
    def friends
      @friends
    end

    # Process the friends.md file and store its contents in internal data
    # structures.
    # @param filename [String] the name of the friends file
    def read_file(filename:)
      @friends = []
      @activities = []

      return unless File.exist?(filename)

      state = :initial
      line_num = 0

      # Loop through all lines in the file and process them.
      File.foreach(filename) do |line|
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
      results = friends.select { |friend| friend.name == name }

      case results.size
      when 0 then nil
      when 1 then results.first
      else raise FriendsError, "More than one friend named #{name}"
      end
    end

    # @param name [String] the name of the friends to search for
    # @return [Array] a list of all friends that match the given text
    def friends_with_similar_name(text)
      friends.select { |friend| text.match(friend.name) }
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
