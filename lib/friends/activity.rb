# frozen_string_literal: true

# Activity represents an activity you've done, usually
# with one or more friends.

require "friends/event"

module Friends
  class Activity < Event
    # @return [Regexp] the string of what we expected during deserialization
    def self.deserialization_expectation
      "[YYYY-MM-DD]: [Activity]"
    end
  end
end
