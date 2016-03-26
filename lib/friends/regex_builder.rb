# frozen_string_literal: true
# RegexpBuilder is an internal class that helps us build regexes to find things.

module Friends
  class RegexBuilder
    # We don't want to match strings that are "escaped" with a leading
    # backslash.
    NO_LEADING_BACKSLASH = "(?<!\\\\)".freeze

    # We don't want to match strings that are directly touching double asterisks
    # as these are treated as sacred by our program.
    NO_LEADING_ASTERISKS = "(?<!\\*\\*)".freeze
    NO_TRAILING_ASTERISKS = "(?!\\*\\*)".freeze

    # We don't want to match strings that are directly touching underscores
    # as these are treated as sacred by our program.
    NO_LEADING_UNDERSCORES = "(?<!_)".freeze
    NO_TRAILING_UNDERSCORES = "(?!_)".freeze

    # We don't want to match strings that are part of other words.
    NO_LEADING_ALPHABETICALS = "(?<![A-z])".freeze
    NO_TRAILING_ALPHABETICALS = "(?![A-z])".freeze

    def self.regex(str)
      Regexp.new(
        NO_LEADING_BACKSLASH +
        NO_LEADING_ASTERISKS +
        NO_LEADING_UNDERSCORES +
        NO_LEADING_ALPHABETICALS +
        str +
        NO_TRAILING_ALPHABETICALS +
        NO_TRAILING_UNDERSCORES +
        NO_TRAILING_ASTERISKS,
        Regexp::IGNORECASE
      )
    end
  end
end
