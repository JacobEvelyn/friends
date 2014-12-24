# Extrovert is the public interface for the friends script. It interacts with
# Introvert for backend computations.

require "friends/introvert"

require "thor"

module Friends
  class Extrovert < Thor
    class_option :verbose, type: :boolean
    class_option :file, type: :string

    desc "clean", "Clean your friends.md file"
    def clean
      Introvert.new(options).clean
    end

    desc "list", "List all friends"
    def list
      puts Introvert.new(options).list
    end
  end
end
