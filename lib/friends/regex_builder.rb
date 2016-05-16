# frozen_string_literal: true

# RegexpBuilder is an internal class that helps us build regexes to find things.

module Friends
  class RegexBuilder
    # We don't want to match strings that are "escaped" with a leading
    # backslash.
    NO_LEADING_BACKSLASH = "(?<!\\\\)"

    # We don't want to match strings that are directly touching double asterisks
    # as these are treated as sacred by our program.
    NO_LEADING_ASTERISKS = "(?<!\\*\\*)"
    NO_TRAILING_ASTERISKS = "(?!\\*\\*)"

    # We don't want to match strings that are directly touching underscores
    # as these are treated as sacred by our program.
    NO_LEADING_UNDERSCORES = "(?<!_)"
    NO_TRAILING_UNDERSCORES = "(?!_)"

    # We don't want to match strings that are part of other words.
    NO_LEADING_ALPHABETICALS = "(?<![A-z])"
    NO_TRAILING_ALPHABETICALS = "(?![A-z])"

    # We ignore case within the regex as opposed to globally to allow consumers
    # of this API the ability to pass in strings that turn off this modifier
    # with the "(?-i)" string.
    IGNORE_CASE = "(?i)"

    def self.regex(str)
      Regexp.new(
        NO_LEADING_BACKSLASH +
        NO_LEADING_ASTERISKS +
        NO_LEADING_UNDERSCORES +
        NO_LEADING_ALPHABETICALS +
        IGNORE_CASE +
        str +
        NO_TRAILING_ALPHABETICALS +
        NO_TRAILING_UNDERSCORES +
        NO_TRAILING_ASTERISKS
      )
    end
  end
end
