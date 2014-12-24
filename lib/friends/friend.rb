# Friend represents a friend. You know, a real-life friend!

module Friends
  class Friend
    # @param name [String] the name of the friend
    def initialize(name:)
      @name = name
    end

    attr_accessor :name
  end
end
