# Extrovert is the public interface for the friends script. It interacts with
# Introvert for backend computations.

require "friends/introvert"

require "thor"

module Friends
  class Extrovert < Thor
    class_option :verbose, type: :boolean

    desc "clean", "Clean your friends.md file"
    def clean
      Introvert.new.clean
    end

    desc "list", "List all friends"
    def list
      Introvert.new.list
    end
  end
end
