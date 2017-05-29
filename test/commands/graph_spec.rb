# frozen_string_literal: true

require "./test/helper"

clean_describe "graph" do
  subject { run_cmd("graph") }

  describe "when file does not exist" do
    it "prints no output" do
      stdout_only ""
    end
  end

  describe "when file is empty" do
    let(:content) { "" }

    it "prints no output" do
      stdout_only ""
    end
  end

  describe "when file has content" do
    let(:content) { CONTENT } # Content must be sorted to avoid errors.

    it "graphs all activities" do
      stdout_only <<-OUTPUT
Nov 2014 |█
Dec 2014 |█
Jan 2015 |█
Feb 2015 |
Mar 2015 |
Apr 2015 |
May 2015 |
Jun 2015 |
Jul 2015 |
Aug 2015 |
Sep 2015 |
Oct 2015 |
Nov 2015 |█
      OUTPUT
    end

    describe "--in" do
      subject { run_cmd("graph --in #{location_name}") }

      describe "when location does not exist" do
        let(:location_name) { "Garbage" }
        it "prints an error message" do
          stderr_only 'Error: No location found for "Garbage"'
        end
      end

      describe "when location exists" do
        let(:location_name) { "paris" }
        it "matches location case-insensitively" do
          stdout_only <<-OUTPUT
Dec 2014 |█
          OUTPUT
        end
      end
    end

    describe "--with" do
      subject { run_cmd("graph --with #{friend_name}") }

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
        let(:friend_name) { "george" }

        it "matches friend case-insensitively" do
          stdout_only <<-OUTPUT
Nov 2014 |█
Dec 2014 |
Jan 2015 |█
          OUTPUT
        end
      end

      describe "when more than one friend name is passed" do
        subject { run_cmd("graph --with #{friend_name1} --with #{friend_name2}") }
        let(:friend_name1) { "george" }
        let(:friend_name2) { "grace" }

        it "matches all friends case-insensitively" do
          stdout_only "Jan 2015 |█"
        end
      end
    end

    describe "--tagged" do
      subject { run_cmd("graph --tagged food") }

      it "matches tag case-sensitively" do
        stdout_only <<-OUTPUT
Jan 2015 |█
Feb 2015 |
Mar 2015 |
Apr 2015 |
May 2015 |
Jun 2015 |
Jul 2015 |
Aug 2015 |
Sep 2015 |
Oct 2015 |
Nov 2015 |█
        OUTPUT
      end

      describe "when more than one tag is passed" do
        subject { run_cmd("graph --tagged #{tag1} --tagged #{tag2}") }
        let(:tag1) { "food" }
        let(:tag2) { "partying" }
        let(:content) do
          <<-FILE
### Activities:
- 2015-01-04: Got lunch with **Grace Hopper** and **George Washington Carver**. @food
- 2015-11-01: **Grace Hopper** and I went to _Marie's Diner_. George had to cancel at the last minute. @food
- 2014-11-15: Talked to **George Washington Carver** on the phone for an hour.
- 2014-12-31: Celebrated the new year in _Paris_ with **Marie Curie**. @partying @food

### Friends:
- George Washington Carver
- Marie Curie [Atlantis] @science
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science
FILE
        end

        it "matches all tags case-sensitively" do
          stdout_only "Dec 2014 |█"
        end
      end
    end

    describe "--since" do
      subject { run_cmd("graph --since 'January 4th 2015'") }

      it "graphs activities on and after the specified date" do
        stdout_only <<-OUTPUT
Jan 2015 |█
Feb 2015 |
Mar 2015 |
Apr 2015 |
May 2015 |
Jun 2015 |
Jul 2015 |
Aug 2015 |
Sep 2015 |
Oct 2015 |
Nov 2015 |█
        OUTPUT
      end
    end

    describe "--after" do
      subject { run_cmd("graph --until 'January 4th 2015'") }

      it "graphs activities before and on the specified date" do
        stdout_only <<-OUTPUT
Nov 2014 |█
Dec 2014 |█
Jan 2015 |█
        OUTPUT
      end
    end
  end
end
