# frozen_string_literal: true

require "./test/helper"

clean_describe "list favorite friends" do
  subject { run_cmd("list favorite friends") }

  describe "when file does not exist" do
    let(:content) { nil }

    it "prints a no-data message" do
      stdout_only "Your favorite friends:"
    end
  end

  describe "when file is empty" do
    let(:content) { "" }

    it "prints a no-data message" do
      stdout_only "Your favorite friends:"
    end
  end

  describe "when file has content" do
    let(:content) do
      <<-FILE
### Activities:
- 2017-01-01: Did some math with **Grace Hopper**.
- 2015-11-01: **Grace Hopper** and I went to Marie's Diner. George had to cancel at the last minute. @food
- 2015-01-04: Got lunch with **Grace Hopper** and **George Washington Carver**. @food
- 2014-12-31: Celebrated the new year in _Paris_ with **Marie Curie**. @partying
- 2014-11-15: Talked to **George Washington Carver** on the phone for an hour.

### Friends:
- George Washington Carver
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science
- Marie Curie [Atlantis] @science
FILE
    end

    it "lists friends in order of decreasing activity" do
      stdout_only <<-OUTPUT
Your favorite friends:
1. Grace Hopper             (3 activities)
2. George Washington Carver (2)
3. Marie Curie              (1)
      OUTPUT
    end

    describe "when friends are tied for the same number of activities" do
      let(:content) do
        <<-FILE
### Activities:
- 2017-01-01: Did something with **Friend A**.
- 2017-01-01: Did something with **Friend A**.
- 2017-01-01: Did something with **Friend B**.
- 2017-01-01: Did something with **Friend B**.
- 2017-01-01: Did something with **Friend C**.
- 2017-01-01: Did something with **Friend D**.
- 2017-01-01: Did something with **Friend E**.
- 2017-01-01: Did something with **Friend F**.
- 2017-01-01: Did something with **Friend G**.
- 2017-01-01: Did something with **Friend H**.
- 2017-01-01: Did something with **Friend I**.
- 2017-01-01: Did something with **Friend J**.

### Friends:
- Friend A
- Friend B
- Friend C
- Friend D
- Friend E
- Friend F
- Friend G
- Friend H
- Friend I
- Friend J
FILE
      end

      it "uses tied ranks" do
        value(subject[:stderr]).must_equal ""
        value(subject[:status]).must_equal 0

        lines = subject[:stdout].split("\n")
        value(lines[1]).must_match(/1\. Friend (A|B)/)
        value(lines[2]).must_match(/1\. Friend (A|B)/)
        value(lines[3]).must_include "3. Friend"
      end

      it "only uses the word 'activities' for the first item, even when a tie" do
        value(subject[:stderr]).must_equal ""
        value(subject[:status]).must_equal 0

        lines = subject[:stdout].split("\n")
        value(lines[1]).must_include "activities"
        value(lines[2]).wont_include "activities"
      end

      it "indents based on the highest rank number, not the number of friends" do
        value(subject[:stderr]).must_equal ""
        value(subject[:status]).must_equal 0

        # Since there are 10 friends, a naive implementation would pad our output
        # assuming the (numerically) highest rank is "10." but since the highest
        # rank is a tie, we never display a double-digit rank, so we don't need to
        # pad our output for double digits.
        lines = subject[:stdout].split("\n")
        value(lines.last).must_include "3. Friend"
      end
    end
  end
end
