# Activity represents an activity you've done with one or more Friends.

module Friends
  class Activity
    def initialize(date:, description:)
      @date = date
      @description = description
    end

    attr_reader :date
    attr_reader :description
  end
end
