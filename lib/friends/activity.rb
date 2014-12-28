# Activity represents an activity you've done with one or more Friends.

require "friends/serializable"

module Friends
  class Activity
    extend Serializable

    SERIALIZATION_PREFIX = "- "

    # @return [Regexp] the regex for capturing groups in deserialization
    def self.deserialization_regex
      /#{SERIALIZATION_PREFIX}(?<date_s>\d{4}-\d\d-\d\d):\s(?<description>.+)/
    end

    # @return [Regexp] the string of what we expected during deserialization
    def self.deserialization_expectation
      "#{SERIALIZATION_PREFIX}[YYYY-MM-DD]: [Activity]"
    end

    # @param date [Date] the activity's date
    # @param description [String] the activity's description
    # @return [Activity] the new activity
    def initialize(date_s:, description:)
      @date = Date.parse(date_s)
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
