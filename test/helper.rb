# frozen_string_literal: true

if ENV["TRAVIS"] == "true" && ENV["CODE_COVERAGE"] == "true"
  require "simplecov"
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
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
- 2018-02-06: @science:indoors:agronomy-with-hydroponics: **Norman Borlaug** and **George Washington Carver** scored a tour of _Atlantis_' hydroponics gardens through wetplants@example.org and they took me along.
- 2015-11-01: **Grace Hopper** and I went to _Martha's Vineyard_. George had to cancel at the last minute.
- 2015-01-04: Got lunch with **Grace Hopper** and **George Washington Carver**. @food
- 2014-12-31: Celebrated the new year in _Paris_ with **Marie Curie**. @partying
- 2014-11-15: Talked to **George Washington Carver** on the phone for an hour.

### Notes:
- 2017-03-12: **Marie Curie** completed her PhD in record time. @school
- 2015-06-15: **Grace Hopper** found out she's getting a big Naval Academy building named after her. @navy
- 2015-06-06: **Marie Curie** just got accepted into a PhD program in _Paris_. @school
- 2015-01-04: **Grace Hopper** and **George Washington Carver** both won an award.

### Friends:
- George Washington Carver
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science
- Marie Curie [Atlantis] @science
- Norman Borlaug (a.k.a. Norm) @science @science:outdoors @science:outdoors:agronomy
- Stanislav Petrov (a.k.a. Stan) @doesnt-trust-computers @doesnt-trust-computers:military-uses

### Locations:
- Atlantis
- Martha's Vineyard
- Paris
FILE

# This is CONTENT but with activities, friends, and locations unsorted.
SCRAMBLED_CONTENT = <<-FILE.freeze
### Activities:
- 2015-01-04: Got lunch with **Grace Hopper** and **George Washington Carver**. @food
- 2015-11-01: **Grace Hopper** and I went to _Martha's Vineyard_. George had to cancel at the last minute.
- 2018-02-06: @science:indoors:agronomy-with-hydroponics: **Norman Borlaug** and **George Washington Carver** scored a tour of _Atlantis_' hydroponics gardens through wetplants@example.org and they took me along.
- 2014-11-15: Talked to **George Washington Carver** on the phone for an hour.
- 2014-12-31: Celebrated the new year in _Paris_ with **Marie Curie**. @partying

### Notes:
- 2015-01-04: **Grace Hopper** and **George Washington Carver** both won an award.
- 2015-06-06: **Marie Curie** just got accepted into a PhD program in _Paris_. @school
- 2017-03-12: **Marie Curie** completed her PhD in record time. @school
- 2015-06-15: **Grace Hopper** found out she's getting a big Naval Academy building named after her. @navy

### Friends:
- George Washington Carver
- Marie Curie [Atlantis] @science
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science
- Stanislav Petrov (a.k.a. Stan) @doesnt-trust-computers @doesnt-trust-computers:military-uses
- Norman Borlaug (a.k.a. Norm) @science @science:outdoors @science:outdoors:agronomy

### Locations:
- Paris
- Atlantis
- Martha's Vineyard
FILE

# Define these methods so they can be referenced in the methods below. They'll be overridden in
# test files.
def filename; end

def subject; end

def run_cmd(command, env_vars: "", **args)
  stdout, stderr, status = Open3.capture3(
    "#{env_vars} bundle exec bin/friends --colorless --filename #{filename} #{command}",
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
  value(subject[:stdout]).must_equal ensure_trailing_newline_unless_empty(expected)
  value(subject[:stderr]).must_equal ""
  value(subject[:status]).must_equal 0
end

def stderr_only(expected)
  value(subject[:stdout]).must_equal ""
  value(subject[:stderr]).must_equal ensure_trailing_newline_unless_empty(expected)
  value(subject[:status]).must_be :>, 0
end

def file_equals(expected)
  subject
  value(File.read(filename)).must_equal expected
end

def line_changed(expected_old, expected_new)
  index = File.read(filename).split("\n").index(expected_old)
  value(index).must_be_kind_of Numeric # Not nil, so we know that `expected_old` was found.
  subject
  value(File.read(filename).split("\n")[index]).must_equal expected_new
end

def line_added(expected)
  n_initial_lines = File.read(filename).split("\n").size
  subject
  lines = File.read(filename).split("\n")
  value(lines).must_include expected # Output includes our line
  value(lines.size).must_equal(n_initial_lines + 1) # Line was added, not changed.
end

def clean_describe(desc, &block)
  describe desc do
    let(:filename) { "test/tmp/friends#{SecureRandom.uuid}.md" }

    before { File.write(filename, content) unless content.nil? }
    after { File.delete(filename) if File.exist?(filename) }

    class_eval(&block)
  end
end
