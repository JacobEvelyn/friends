# frozen_string_literal: true

module Friends
  module SemVerComparator
    SEPARATOR = "."
    NUMBER_REGEX = /\d+/.freeze

    def self.greater?(version_a, version_b)
      version_a.split(SEPARATOR).zip(version_b.split(SEPARATOR)) do |a, b|
        a_num = a&.[](NUMBER_REGEX)&.to_i
        b_num = b&.[](NUMBER_REGEX)&.to_i
        return false if a_num.nil?
        return true if b_num.nil? || a_num > b_num
        return false if a_num < b_num
      end

      false
    end
  end
end
