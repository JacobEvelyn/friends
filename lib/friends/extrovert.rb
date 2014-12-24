# Extrovert is the public interface for the friends script. It interacts with
# Introvert for backend computations.

require "friends/friends_error"
require "friends/introvert"

require "thor"

module Friends
  class Extrovert < Thor
    class_option :verbose, type: :boolean
    class_option :file, type: :string

    desc "add [FRIEND NAME]", "Add a friend"
    # Add a friend and write out the new friends file.
    # @param name [String] the name of the friend to add
    def add(name)
      Introvert.new(options).add(name: name)
    rescue FriendsError => e
      error e
    end

    desc "clean", "Clean your friends.md file"
    # Write out the friends file with cleaned/sorted data.
    def clean
      Introvert.new(options).clean
    rescue FriendsError => e
      error e
    end

    desc "list", "List all friends"
    # List all friends in the friends file.
    def list
      puts Introvert.new(options).list
    rescue FriendsError => e
      error e
    end

    private

    # Output the given message to STDERR and exit the program.
    # @param message [String] the error message to output
    def error(message)
      abort "Error: #{message}"
    end
  end
end
