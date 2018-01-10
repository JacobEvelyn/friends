# frozen_string_literal: true

# Note represents a note--a dated record of something
# about friends or locations that isn't an activity
# you did. Notes are a good way to remember things big
# and small, like when your friends move, change jobs,
# get engaged, or just what food allergies they have
# for the next time you have them over for dinner.

require "friends/event"

module Friends
  class Note < Event
    # @return [Regexp] the string of what we expected during deserialization
    def self.deserialization_expectation
      "[YYYY-MM-DD]: [Note]"
    end
  end
end
