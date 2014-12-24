# Introvert is the internal handler for the friends script.

require "friends/friend"

module Friends
  class Introvert
    FRIENDS_HEADER = "### Friends:"

    # Write out the friends file with cleaned/sorted data.
    def clean
      names = friends.sort_by(&:name).map { |friend| "- #{friend.name}" }
      File.open(filename, "w") do |file|
        file.puts(FRIENDS_HEADER)
        names.each { |name| file.puts(name) }
      end
    end

    # List all friends in the friends file.
    def list
      puts friends.map(&:name)
    end

    private

    # @return [String] the name of the friends.md file
    def filename
      "friends.md"
    end

    # @return [Array] the list of all Friends
    def friends
      return @friends if @friends

      read_file(filename: filename, friends_only: true)
      @friends
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
          if line == "### Events:"
            state = :reading_events
          else
            match = line.match(/- (?<name>.+)/)
            bad_line("- [Friend Name]", line_num) unless match && match[:name]
            @friends << Friend.new(name: match[:name])
          end
        end
      end
    end

    # Raise an error that a line in the friends file is malformed.
    # @param expected [String] the expected contents of the line
    # @param line_num [Integer] the line number
    def bad_line(expected, line_num)
      error "Expected \"#{expected}\" on line #{line_num}"
    end

    # Output the given message to STDERR and exit the program.
    # @param message [String] the error message to output
    def error(message)
      abort "Error: #{message}"
    end
  end
end
