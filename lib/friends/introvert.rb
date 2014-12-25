# Introvert is the internal handler for the friends script.

require "friends/friend"
require "friends/friends_error"

module Friends
  class Introvert
    DEFAULT_FILENAME = "./friends.md"
    ACTIVITIES_HEADER = "### Activities:"
    ACTIVITY_PREFIX = "- "
    FRIENDS_HEADER = "### Friends:"
    FRIEND_PREFIX = "- "

    # @param filename [String] the name of the friends Markdown file
    def initialize(filename: DEFAULT_FILENAME, verbose: false)
      @filename = filename
      @verbose = verbose
      @cleaned_file = false # Switches to true when the file is cleaned.
    end

    attr_reader :filename
    attr_reader :verbose

    # Write out the friends file with cleaned/sorted data.
    def clean
      # Short-circuit if we've already cleaned the file so we don't write it
      # twice.
      return if @cleaned_file

      names = friends.sort_by(&:name).map do |friend|
        "#{FRIEND_PREFIX}#{friend.name}"
      end

      File.open(filename, "w") do |file|
        file.puts(FRIENDS_HEADER)
        names.each { |name| file.puts(name) }
      end

      @cleaned_file = true
    end

    # List all friend names in the friends file.
    # @return [Array] a list of all friend names
    def list_friends
      friends.map(&:name)
    end

    # Add a friend and write out the new friends file.
    # @param name [String] the name of the friend to add
    # @raise [FriendsError] when a friend with that name is already in the file
    def add_friend(name:)
      if friend_with_exact_name(name)
        raise FriendsError, "Friend named #{name} already exists"
      end

      friends << Friend.new(name: name)
      clean # Write a cleaned file.
    end

    # List all activity details
    # @return [Array] a list of all activity text values
    def list_activities
      activites.map(&:name)
    end

    private

    # Gets the list of friends, reading the friends file if it hasn't been read
    # already.
    # @return [Array] a list of all friends
    def friends
      return @friends if @friends

      read_file(filename: filename, friends_only: true)
      @friends
    end

    # Gets the list of activites, reading the friends file if it hasn't been
    # read already.
    # @return [Array] a list of all activities
    def activities
      return @activities if @activities

      read_file(filename: filename)
      @activities
    end

    # Process the friends.md file and store its contents in internal data
    # structures.
    # @param filename [String] the name of the friends file
    # @param friends_only [Boolean] true if we should only read the friends list
    def read_file(filename:, friends_only: false)
      state = :initial
      line_num = 0

      # Loop through all lines in the file and process them.
      File.foreach(filename) do |line|
        line_num += 1
        line.chomp! # Remove trailing newline from each line.

        case state
        when :initial
          bad_line(FRIENDS_HEADER, line_num) unless line == FRIENDS_HEADER

          state = :reading_friends
          @friends = []
        when :reading_friends
          if line == ""
            return if friends_only
            state = :done_reading_friends
          else
            match = line.match(/#{FRIEND_PREFIX}(?<name>.+)/)
            unless match && match[:name]
              bad_line("#{FRIEND_PREFIX}[Friend Name]", line_num)
            end
            @friends << Friend.new(name: match[:name])
          end
        when :done_reading_friends
          if line == ACTIVITIES_HEADER
            state = :reading_activities
            @activities = []
          end
        when :reading_activities
          match = line.match(/#{ACTIVITY_PREFIX}(?<description>.+)/)
          unless match && match[:description]
            bad_line("#{ACTIVITY_PREFIX}[Activity]", line_num)
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
    # @return [Array] a list of all friends that match the given name
    def friends_with_similar_name(name)
      friends.select { |friend| friend.name.match(name) }
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
