# frozen_string_literal: true

if ENV["TRAVIS"] == "true"
  require "simplecov"
  require "coveralls"
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter "/test/"
  end
end

ENV["MT_HELL"] = "1" # Forces tests to have at least one assertion to pass.

require "minitest/autorun"

# Runs tests in parallel. Also, in combination with the MT_HELL environment var
# set above and the loading of the `minitest-proveit` gem, requires that tests
# have at least one assertion to pass.
require "minitest/hell"

require "minitest/pride"
require "open3"
require "securerandom"

require "friends"

CONTENT = <<-FILE.freeze
### Activities:
- 2015-11-01: **Grace Hopper** and I went to _Marie's Diner_. George had to cancel at the last minute. @food
- 2015-01-04: Got lunch with **Grace Hopper** and **George Washington Carver**. @food
- 2014-12-31: Celebrated the new year in _Paris_ with **Marie Curie**. @partying
- 2014-11-15: Talked to **George Washington Carver** on the phone for an hour.

### Friends:
- George Washington Carver
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science
- Marie Curie [Atlantis] @science

### Locations:
- Atlantis
- Marie's Diner
- Paris
FILE

# This is CONTENT but with activities, friends, and locations unsorted.
SCRAMBLED_CONTENT = <<-FILE.freeze
### Activities:
- 2015-01-04: Got lunch with **Grace Hopper** and **George Washington Carver**. @food
- 2015-11-01: **Grace Hopper** and I went to _Marie's Diner_. George had to cancel at the last minute. @food
- 2014-11-15: Talked to **George Washington Carver** on the phone for an hour.
- 2014-12-31: Celebrated the new year in _Paris_ with **Marie Curie**. @partying

### Friends:
- George Washington Carver
- Marie Curie [Atlantis] @science
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science

### Locations:
- Paris
- Atlantis
- Marie's Diner
FILE

# Define these methods so they can be referenced in the methods below. They'll be overridden in
# test files.
def filename; end

def subject; end

def run_cmd(command, **args)
  stdout, stderr, status = Open3.capture3(
    "bundle exec bin/friends --colorless --filename #{filename} #{command}",
    **args
  )
  {
    stdout: stdout,
    stderr: stderr,
    status: status.exitstatus
  }
end

# @param str [String] a string
# @return [String] the input string with a newline appended to it if one was not already
#   present, *unless* the string is empty
def ensure_trailing_newline_unless_empty(str)
  return "" if str.empty?

  str.to_s[-1] == "\n" ? str.to_s : "#{str}\n"
end

def stdout_only(expected)
  puts subject[:stderr] unless subject[:stderr] == ""
  subject[:stdout].must_equal ensure_trailing_newline_unless_empty(expected)
  subject[:stderr].must_equal ""
  subject[:status].must_equal 0
end

def stderr_only(expected)
  subject[:stdout].must_equal ""
  subject[:stderr].must_equal ensure_trailing_newline_unless_empty(expected)
  subject[:status].must_be :>, 0
end

def file_equals(expected)
  subject
  File.read(filename).must_equal expected
end

def line_changed(expected_old, expected_new)
  index = File.read(filename).split("\n").index(expected_old)
  index.must_be_kind_of Numeric # Not nil, so we know that `expected_old` was found.
  subject
  File.read(filename).split("\n")[index].must_equal expected_new
end

def line_added(expected)
  n_initial_lines = File.read(filename).split("\n").size
  subject
  lines = File.read(filename).split("\n")
  lines.index(expected).must_be_kind_of Numeric # Not nil, so we know that `expected` was found.
  lines.size.must_equal(n_initial_lines + 1) # Line was added, not changed.
end

def clean_describe(desc, *additional_desc, &block)
  describe desc, *additional_desc do
    let(:filename) { "test/tmp/friends#{SecureRandom.uuid}.md" }

    before { File.write(filename, content) unless content.nil? }
    after { File.delete(filename) if File.exist?(filename) }

    class_eval(&block)
  end
end
