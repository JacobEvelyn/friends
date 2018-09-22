# frozen_string_literal: true

require "./test/helper"

clean_describe "list notes" do
  subject { run_cmd("list notes") }

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

    it "lists notes in file order" do
      stdout_only <<-OUTPUT
2015-01-04: Grace Hopper and George Washington Carver both won an award.
2015-06-06: Marie Curie just got accepted into a PhD program in Paris. @school
2017-03-12: Marie Curie completed her PhD in record time. @school
2015-06-15: Grace Hopper found out she's getting a big Naval Academy building named after her. @navy
      OUTPUT
    end

    describe "--in" do
      subject { run_cmd("list notes --in #{location_name}") }

      describe "when location does not exist" do
        let(:location_name) { "Garbage" }
        it "prints an error message" do
          stderr_only 'Error: No location found for "Garbage"'
        end
      end

      describe "when location exists" do
        let(:location_name) { "paris" }
        it "matches location case-insensitively" do
          stdout_only "2015-06-06: "\
                      "Marie Curie just got accepted into a PhD program in Paris. @school"
        end
      end
    end

    describe "--with" do
      subject { run_cmd("list notes --with #{friend_name}") }

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
        let(:friend_name) { "grace" }
        it "matches friend case-insensitively" do
          stdout_only <<-OUTPUT
2015-01-04: Grace Hopper and George Washington Carver both won an award.
2015-06-15: Grace Hopper found out she's getting a big Naval Academy building named after her. @navy
          OUTPUT
        end
      end

      describe "when more than one friend name is passed" do
        subject { run_cmd("list notes --with #{friend_name1} --with #{friend_name2}") }
        let(:friend_name1) { "george" }
        let(:friend_name2) { "grace" }

        it "matches all friends case-insensitively" do
          stdout_only "2015-01-04: Grace Hopper and George Washington Carver both won an award."
        end
      end
    end

    describe "--tagged" do
      subject { run_cmd("list notes --tagged school") }

      it "matches tag case-sensitively" do
        stdout_only <<-OUTPUT
2015-06-06: Marie Curie just got accepted into a PhD program in Paris. @school
2017-03-12: Marie Curie completed her PhD in record time. @school
        OUTPUT
      end

      describe "when more than one tag is passed" do
        subject { run_cmd("list notes --tagged #{tag1} --tagged #{tag2}") }
        let(:tag1) { "science" }
        let(:tag2) { "school" }
        let(:content) do
          <<-FILE
### Notes:
- 2015-01-04: **Grace Hopper** and **George Washington Carver** both won an award. @recognition
- 2015-11-01: **Grace Hopper** just started a PhD program. @school @science
- 2014-11-15: **Marie Curie** made some amazing scientific discoveries today. @science
- 2014-12-31: **Marie Curie** completed her PhD today! @science @school

### Friends:
- George Washington Carver
- Marie Curie [Atlantis] @science
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science
FILE
        end

        it "matches all tags case-sensitively" do
          stdout_only <<-OUTPUT
2015-11-01: Grace Hopper just started a PhD program. @school @science
2014-12-31: Marie Curie completed her PhD today! @science @school
          OUTPUT
        end
      end
    end

    describe "--since" do
      subject { run_cmd("list notes --since 'June 15th 2015'") }

      it "lists notes on and after the specified date" do
        stdout_only <<-OUTPUT
2017-03-12: Marie Curie completed her PhD in record time. @school
2015-06-15: Grace Hopper found out she's getting a big Naval Academy building named after her. @navy
        OUTPUT
      end
    end

    describe "--until" do
      subject { run_cmd("list notes --until 'June 15th 2015'") }

      it "lists notes before and on the specified date" do
        stdout_only <<-OUTPUT
2015-01-04: Grace Hopper and George Washington Carver both won an award.
2015-06-06: Marie Curie just got accepted into a PhD program in Paris. @school
2015-06-15: Grace Hopper found out she's getting a big Naval Academy building named after her. @navy
        OUTPUT
      end
    end
  end
end
