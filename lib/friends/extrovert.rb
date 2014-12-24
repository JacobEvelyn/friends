# Extrovert is the public interface for the friends script. It interacts with
# Introvert for backend computations.

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
    end

    desc "clean", "Clean your friends.md file"
    # Write out the friends file with cleaned/sorted data.
    def clean
      Introvert.new(options).clean
    end

    desc "list", "List all friends"
    # List all friends in the friends file.
    def list
      puts Introvert.new(options).list
    end
  end
end
