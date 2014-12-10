# Extrovert is the public interface for the friends script. It interacts with
# an Introvert for backend computations.

require "friends/introvert"

require "thor"

module Friends
  class Extrovert < Thor
    def initialize(*args)
      super
      @introvert = Introvert.new
    end

    attr_reader :introvert

    class_option :verbose, type: :boolean

    desc "clean", "Cleans your friends.md file"
    def clean
      introvert.clean
    end

    desc "list", "List all friends"
    def list
      puts introvert.friends.map(&:name)
    end
  end
end
