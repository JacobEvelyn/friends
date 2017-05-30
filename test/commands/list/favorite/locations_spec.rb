# frozen_string_literal: true

require "./test/helper"

clean_describe "list favorite locations" do
  subject { run_cmd("list favorite locations") }

  describe "when file does not exist" do
    let(:content) { nil }

    it "prints a no-data message" do
      stdout_only "Your favorite locations:"
    end
  end

  describe "when file is empty" do
    let(:content) { "" }

    it "prints a no-data message" do
      stdout_only "Your favorite locations:"
    end
  end

  describe "when file has content" do
    let(:content) do
      <<-FILE
### Activities:
- 2017-01-01: **Grace Hopper** and I went to _Marie's Diner_ for breakfast.
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
    end

    it "lists locations in order of decreasing activity" do
      stdout_only <<-OUTPUT
Your favorite locations:
1. Marie's Diner (2 activities)
2. Paris         (1)
3. Atlantis      (0)
      OUTPUT
    end

    describe "when locations are tied for the same number of activities" do
      let(:content) do
        <<-FILE
### Activities:
- 2017-01-01: Did something in _Location A_.
- 2017-01-01: Did something in _Location A_.
- 2017-01-01: Did something in _Location B_.
- 2017-01-01: Did something in _Location B_.
- 2017-01-01: Did something in _Location C_.
- 2017-01-01: Did something in _Location D_.
- 2017-01-01: Did something in _Location E_.
- 2017-01-01: Did something in _Location F_.
- 2017-01-01: Did something in _Location G_.
- 2017-01-01: Did something in _Location H_.
- 2017-01-01: Did something in _Location I_.
- 2017-01-01: Did something in _Location J_.

### Locations:
- Location A
- Location B
- Location C
- Location D
- Location E
- Location F
- Location G
- Location H
- Location I
- Location J
FILE
      end

      it "uses tied ranks" do
        subject[:stderr].must_equal ""
        subject[:status].must_equal 0

        lines = subject[:stdout].split("\n")
        lines[1].must_match(/1\. Location (A|B)/)
        lines[2].must_match(/1\. Location (A|B)/)
        lines[3].must_include "3. Location"
      end

      it "only uses the word 'activities' for the first item, even when a tie" do
        subject[:stderr].must_equal ""
        subject[:status].must_equal 0

        lines = subject[:stdout].split("\n")
        lines[1].must_include "activities"
        lines[2].wont_include "activities"
      end

      it "indents based on the highest rank number, not the number of locations" do
        subject[:stderr].must_equal ""
        subject[:status].must_equal 0

        # Since there are 10 friends, a naive implementation would pad our output
        # assuming the (numerically) highest rank is "10." but since the highest
        # rank is a tie, we never display a double-digit rank, so we don't need to
        # pad our output for double digits.
        lines = subject[:stdout].split("\n")
        lines.last.must_include "3. Location"
      end
    end

    describe "--limit" do
      subject { run_cmd("list favorite locations --limit #{limit}") }

      describe "when limit is less than 1" do
        let(:limit) { 0 }
        it "prints an error message" do
          stderr_only "Error: Favorites limit must be positive"
        end
      end

      describe "when limit is 1" do
        let(:limit) { 1 }

        it "uses correct location pluralization" do
          stdout_only "Your favorite location is Marie's Diner (2 activities)"
        end

        describe "when favorite location only has one activity" do
          let(:content) do
            <<-FILE
### Activities:
- 2017-01-01: Did some math with **Grace Hopper** at _Marie's Diner_.

### Friends:
- George Washington Carver
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science
- Marie Curie [Atlantis] @science

### Locations:
- Atlantis
- Marie's Diner
- Paris
FILE
          end

          it "uses correct activity pluralization" do
            stdout_only "Your favorite location is Marie's Diner (1 activity)"
          end
        end
      end

      describe "when limit is greater than 1" do
        let(:limit) { 2 }
        it "limits output to the number specified" do
          stdout_only <<-OUTPUT
Your favorite locations:
1. Marie's Diner (2 activities)
2. Paris         (1)
          OUTPUT
        end
      end
    end
  end
end
