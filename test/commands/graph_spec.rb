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
Nov 2014 |
Dec 2014 |█
Jan 2015 |
Feb 2015 |
Mar 2015 |
Apr 2015 |
May 2015 |
Jun 2015 |
Jul 2015 |
Aug 2015 |
Sep 2015 |
Oct 2015 |
Nov 2015 |
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
Feb 2015 |
Mar 2015 |
Apr 2015 |
May 2015 |
Jun 2015 |
Jul 2015 |
Aug 2015 |
Sep 2015 |
Oct 2015 |
Nov 2015 |
          OUTPUT
        end
      end
    end

    describe "--tagged" do
      subject { run_cmd("graph --tagged food") }

      it "matches tag case-sensitively" do
        stdout_only <<-OUTPUT
Nov 2014 |
Dec 2014 |
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
  end
end
