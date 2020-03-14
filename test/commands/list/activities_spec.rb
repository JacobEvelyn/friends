# frozen_string_literal: true

require "./test/helper"

clean_describe "list activities" do
  subject { run_cmd("list activities") }

  describe "when file does not exist" do
    let(:content) { nil }

    it "does not list anything" do
      stdout_only ""
    end
  end

  describe "when file is empty" do
    let(:content) { "" }

    it "does not list anything" do
      stdout_only ""
    end
  end

  describe "when file has content" do
    # Use scrambled content to differentiate between output that is sorted and output that
    # only reads from the (usually-sorted) file.
    let(:content) { SCRAMBLED_CONTENT }

    it "lists activities in file order" do
      stdout_only <<-OUTPUT
2015-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
2015-11-01: Grace Hopper and I went to Martha's Vineyard. George had to cancel at the last minute.
2018-02-06: @science:indoors:agronomy-with-hydroponics: Norman Borlaug and George Washington Carver scored a tour of Atlantis' hydroponics gardens through wetplants@example.org and they took me along.
2014-11-15: Talked to George Washington Carver on the phone for an hour.
2014-12-31: Celebrated the new year in Paris with Marie Curie. @partying
      OUTPUT
    end

    describe "--in" do
      subject { run_cmd("list activities --in #{location_name}") }

      describe "when location does not exist" do
        let(:location_name) { "Garbage" }
        it "prints an error message" do
          stderr_only 'Error: No location found for "Garbage"'
        end
      end

      describe "when location exists" do
        let(:location_name) { "paris" }
        it "matches location case-insensitively" do
          stdout_only "2014-12-31: Celebrated the new year in Paris with Marie Curie. @partying"
        end
      end

      describe "when implicit location is set" do
        let(:location_name) { "atlantis" }
        describe 'when activities are in order' do
          let(:content) do
            <<-FILE
### Activities:
- 2000-01-06: Went to a museum with **George Washington Carver**.
- 2000-01-05: Moved to _Paris_.
- 2000-01-04: Got lunch with **Grace Hopper** and **George Washington Carver**. @food
- 2000-01-03: Celebrated my birthday in _Paris_ with **Marie Curie**. @partying @food
- 2000-01-02: Went to _Atlantis_.
- 2000-01-01: Talked to **George Washington Carver** on the phone for an hour.

### Friends:
- George Washington Carver
- Marie Curie [Atlantis] @science
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science

### Locations:
- Atlantis
- Paris
            FILE
          end

          it "matches location case-insensitively" do
            stdout_only <<-OUTPUT
2000-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
2000-01-02: Went to Atlantis.
          OUTPUT
          end
        end
        describe 'when activities are not in order' do
          let(:content) do
            <<-FILE
### Activities:
- 2000-01-06: Went to a museum with **George Washington Carver**.
- 2000-01-02: Went to _Atlantis_.
- 2000-01-04: Got lunch with **Grace Hopper** and **George Washington Carver**. @food
- 2000-01-03: Celebrated my birthday in _Paris_ with **Marie Curie**. @partying @food
- 2000-01-05: Moved to _Paris_.
- 2000-01-01: Talked to **George Washington Carver** on the phone for an hour.

### Friends:
- George Washington Carver
- Marie Curie [Atlantis] @science
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science

### Locations:
- Atlantis
- Paris
            FILE
          end

          it "matches location case-insensitively" do
            stdout_only <<-OUTPUT
2000-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
2000-01-02: Went to Atlantis.
          OUTPUT
          end
        end
      end
    end
    describe "--with" do
      subject { run_cmd("list activities --with #{friend_name}") }

      describe "when friend does not exist" do
        let(:friend_name) { "Garbage" }
        it "prints an error message" do
          stderr_only 'Error: No friend found for "Garbage"'
        end
      end

      describe "when friend name matches more than one friend" do
        let(:friend_name) { "george" }
        before { run_cmd("add friend George Harrison") }
        it "prints an error message" do
          stderr_only 'Error: More than one friend found for "george": '\
                      "George Harrison, George Washington Carver"
        end
      end

      describe "when friend name matches one friend" do
        let(:friend_name) { "marie" }
        it "matches friend case-insensitively" do
          stdout_only "2014-12-31: Celebrated the new year in Paris with Marie Curie. @partying"
        end
      end

      describe "when more than one friend name is passed" do
        subject { run_cmd("list activities --with #{friend_name1} --with #{friend_name2}") }
        let(:friend_name1) { "george" }
        let(:friend_name2) { "grace" }

        it "matches all friends case-insensitively" do
          stdout_only "2015-01-04: Got lunch with Grace Hopper and George Washington Carver. @food"
        end
      end
    end

    describe "--tagged" do
      subject { run_cmd("list activities --tagged FOOD") }

      it "matches tag case-insensitively" do
        stdout_only <<-OUTPUT
2015-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
        OUTPUT
      end

      describe "when more than one tag is passed" do
        subject { run_cmd("list activities --tagged #{tag1} --tagged #{tag2}") }
        let(:tag1) { "Food" }
        let(:tag2) { "PARTYING" }
        let(:content) do
          <<-FILE
### Activities:
- 2015-01-04: Got lunch with **Grace Hopper** and **George Washington Carver**. @food
- 2015-11-01: **Grace Hopper** and I went to _Martha's Vineyard_. George had to cancel at the last minute.
- 2014-11-15: Talked to **George Washington Carver** on the phone for an hour.
- 2014-12-31: Celebrated the new year in _Paris_ with **Marie Curie**. @partying @food

### Friends:
- George Washington Carver
- Marie Curie [Atlantis] @science
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science
FILE
        end

        it "matches all tags case-insensitively" do
          stdout_only(
            "2014-12-31: Celebrated the new year in Paris with Marie Curie. @partying @food"
          )
        end
      end
    end

    describe "--since" do
      subject { run_cmd("list activities --since 'January 4th 2015'") }

      it "lists activities on and after the specified date" do
        stdout_only <<-OUTPUT
2015-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
2015-11-01: Grace Hopper and I went to Martha's Vineyard. George had to cancel at the last minute.
2018-02-06: @science:indoors:agronomy-with-hydroponics: Norman Borlaug and George Washington Carver scored a tour of Atlantis' hydroponics gardens through wetplants@example.org and they took me along.
        OUTPUT
      end
    end

    describe "--until" do
      subject { run_cmd("list activities --until 'January 4th 2015'") }

      it "lists activities before and on the specified date" do
        stdout_only <<-OUTPUT
2015-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
2014-11-15: Talked to George Washington Carver on the phone for an hour.
2014-12-31: Celebrated the new year in Paris with Marie Curie. @partying
        OUTPUT
      end
    end
  end
end
