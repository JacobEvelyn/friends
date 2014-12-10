# Gossip is the interface that writes to the user interface from the Introvert.

module Friends
  class Gossip
    # Exit the program and print the given error message.
    def self.error(message)
      abort "Error: #{message}"
    end
  end
end
