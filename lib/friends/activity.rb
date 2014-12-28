# Activity represents an activity you've done with one or more Friends.

module Friends
  class Activity
    SERIALIZATION_PREFIX = "- "

    # @param str [String] the serialized activity string
    # @return [Activity] the activity represented by the serialized string
    def self.deserialize(str)
      match = str.match(
        /#{SERIALIZATION_PREFIX}(?<date>\d{4}-\d\d-\d\d):\s(?<description>.+)/
      )
      unless match && match[:date] && match[:description]
        raise FriendsError,
              "Expected #{SERIALIZATION_PREFIX}[YYYY-MM-DD]: [Activity]"
      end

      Activity.new(
        date: Date.parse(match[:date]),
        description: match[:description]
      )
    end

    # @param date [Date] the activity's date
    # @param description [String] the activity's description
    # @return [Activity] the new activity
    def initialize(date:, description:)
      @date = date
      @description = description
    end

    attr_reader :date
    attr_reader :description

    # @return [String] the command-line display text for the activity
    def display_text
      date_s = "\e[1m#{date}\e[0m"
      description_s = description
      while match = description_s.match(/(\*\*)([^\*]+)(\*\*)/)
        description_s =
          "#{match.pre_match}\e[1m#{match[2]}\e[0m#{match.post_match}"
      end
      "#{date_s}: #{description_s}"
    end

    # @return [String] the file serialization text for the activity
    def serialize
      "#{SERIALIZATION_PREFIX}#{date}: #{description}"
    end

    private

    # Default sorting for an array of activities is reverse-date.
    def <=>(other)
      other.date <=> date
    end
  end
end
