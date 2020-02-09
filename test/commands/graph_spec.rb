# frozen_string_literal: true

require "./test/helper"

clean_describe "graph" do
  subject { run_cmd("graph#{' --unscaled' if unscaled}") }
  let(:unscaled) { false }

  describe "when file does not exist" do
    let(:content) { nil }

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
    # Content must be sorted to avoid errors.
    let(:content) do
      <<-FILE
### Activities:
- 2015-11-01: **Grace Hopper** and I went to _Martha's Vineyard_. George had to cancel at the last minute.
- 2015-01-14: Got lunch with **Grace Hopper** and **George Washington Carver**. @food
- 2015-01-06: Did some other things in _Paris_.
- 2015-01-06: Did even more things in _Paris_.
- 2015-01-05: Did even more things in _Paris_.
- 2014-12-31: Celebrated the new year in _Paris_ with **Marie Curie**. @partying @food
- 2014-11-15: Talked to **George Washington Carver** on the phone for an hour.

### Friends:
- George Washington Carver
- Marie Curie [Atlantis] @science
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science

### Locations:
- Atlantis
- Martha's Vineyard
- Paris
      FILE
    end

    it "graphs all activities, scaled" do
      stdout_only <<-OUTPUT
Nov 2015 |█████∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Oct 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Sep 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Aug 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jul 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jun 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
May 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Apr 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Mar 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Feb 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jan 2015 |████████████████████
Dec 2014 |█████∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Nov 2014 |█████∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
      OUTPUT
    end

    describe "--unscaled" do
      let(:unscaled) { true }

      it "graphs all activities, unscaled" do
        stdout_only <<-OUTPUT
Nov 2015 |█
Oct 2015 |
Sep 2015 |
Aug 2015 |
Jul 2015 |
Jun 2015 |
May 2015 |
Apr 2015 |
Mar 2015 |
Feb 2015 |
Jan 2015 |████
Dec 2014 |█
Nov 2014 |█
        OUTPUT
      end
    end

    describe "when there are more activities than colors" do
      let(:content) do
        (["### Activities:"] + (["- 2017-06-01: Did something."] * 100)).join("\n")
      end
      let(:unscaled) { true }

      it "displays the correct number of activities" do
        stdout_only("Jun 2017 |" + ("█" * 100))
      end
    end

    describe "--in" do
      subject { run_cmd("graph#{' --unscaled' if unscaled} --in #{location_name}") }

      describe "when location does not exist" do
        let(:location_name) { "Garbage" }
        it "prints an error message" do
          stderr_only 'Error: No location found for "Garbage"'
        end
      end

      describe "when location exists" do
        let(:location_name) { "paris" }

        it "matches location case-insensitively and scales the graph" do
          stdout_only <<-OUTPUT
Nov 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Oct 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Sep 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Aug 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jul 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jun 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
May 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Apr 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Mar 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Feb 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jan 2015 |███████████████∙∙∙∙∙|
Dec 2014 |█████∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Nov 2014 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
          OUTPUT
        end

        describe "--unscaled" do
          let(:unscaled) { true }

          it "matches location case-insensitively and does not scale graph" do
            stdout_only <<-OUTPUT
Nov 2015 |∙|
Oct 2015 |
Sep 2015 |
Aug 2015 |
Jul 2015 |
Jun 2015 |
May 2015 |
Apr 2015 |
Mar 2015 |
Feb 2015 |
Jan 2015 |███∙|
Dec 2014 |█
Nov 2014 |∙|
            OUTPUT
          end
        end
      end
    end

    describe "--with" do
      subject { run_cmd("graph#{' --unscaled' if unscaled} --with #{friend_name}") }

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

        it "matches friend case-insensitively and scales the graph" do
          stdout_only <<-OUTPUT
Nov 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Oct 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Sep 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Aug 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jul 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jun 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
May 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Apr 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Mar 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Feb 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jan 2015 |█████∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Dec 2014 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Nov 2014 |█████∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
          OUTPUT
        end

        describe "--unscaled" do
          let(:unscaled) { true }

          it "matches friend case-insensitively and does not scale graph" do
            stdout_only <<-OUTPUT
Nov 2015 |∙|
Oct 2015 |
Sep 2015 |
Aug 2015 |
Jul 2015 |
Jun 2015 |
May 2015 |
Apr 2015 |
Mar 2015 |
Feb 2015 |
Jan 2015 |█∙∙∙|
Dec 2014 |∙|
Nov 2014 |█
            OUTPUT
          end
        end
      end

      describe "when more than one friend name is passed" do
        subject do
          run_cmd(
            "graph#{' --unscaled' if unscaled} --with #{friend_name1} --with #{friend_name2}"
          )
        end

        let(:friend_name1) { "george" }
        let(:friend_name2) { "grace" }

        it "matches all friends case-insensitively and scales the graph" do
          stdout_only <<-OUTPUT
Nov 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Oct 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Sep 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Aug 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jul 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jun 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
May 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Apr 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Mar 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Feb 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jan 2015 |█████∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Dec 2014 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Nov 2014 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
          OUTPUT
        end

        describe "--unscaled" do
          let(:unscaled) { true }

          it "matches all friends case-insensitively and does not scale graph" do
            stdout_only <<-OUTPUT
Nov 2015 |∙|
Oct 2015 |
Sep 2015 |
Aug 2015 |
Jul 2015 |
Jun 2015 |
May 2015 |
Apr 2015 |
Mar 2015 |
Feb 2015 |
Jan 2015 |█∙∙∙|
Dec 2014 |∙|
Nov 2014 |∙|
            OUTPUT
          end
        end
      end
    end

    describe "--tagged" do
      subject { run_cmd("graph#{' --unscaled' if unscaled} --tagged Food") }

      it "matches tag case-insensitively and scales the graph" do
        stdout_only <<-OUTPUT
Nov 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Oct 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Sep 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Aug 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jul 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jun 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
May 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Apr 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Mar 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Feb 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jan 2015 |█████∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Dec 2014 |█████∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Nov 2014 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
        OUTPUT
      end

      describe "--unscaled" do
        let(:unscaled) { true }

        it "matches tag case-insensitively and does not scale graph" do
          stdout_only <<-OUTPUT
Nov 2015 |∙|
Oct 2015 |
Sep 2015 |
Aug 2015 |
Jul 2015 |
Jun 2015 |
May 2015 |
Apr 2015 |
Mar 2015 |
Feb 2015 |
Jan 2015 |█∙∙∙|
Dec 2014 |█
Nov 2014 |∙|
        OUTPUT
        end
      end

      describe "when more than one tag is passed" do
        subject { run_cmd("graph#{' --unscaled' if unscaled} --tagged #{tag1} --tagged #{tag2}") }
        let(:tag1) { "Food" }
        let(:tag2) { "PARTYING" }

        it "matches all tags case-insensitively and scales the graph" do
          stdout_only <<-OUTPUT
Nov 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Oct 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Sep 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Aug 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jul 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jun 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
May 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Apr 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Mar 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Feb 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jan 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Dec 2014 |█████∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Nov 2014 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
          OUTPUT
        end

        describe "--unscaled" do
          let(:unscaled) { true }

          it "matches all tags case-insensitively and does not scale graph" do
            stdout_only <<-OUTPUT
Nov 2015 |∙|
Oct 2015 |
Sep 2015 |
Aug 2015 |
Jul 2015 |
Jun 2015 |
May 2015 |
Apr 2015 |
Mar 2015 |
Feb 2015 |
Jan 2015 |∙∙∙∙|
Dec 2014 |█
Nov 2014 |∙|
            OUTPUT
          end
        end
      end
    end

    describe "--since" do
      subject { run_cmd("graph#{' --unscaled' if unscaled} --since 'January 6th 2015'") }

      it "graphs activities on and after the specified date and scales the graph" do
        stdout_only <<-OUTPUT
Nov 2015 |█████∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Oct 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Sep 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Aug 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jul 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jun 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
May 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Apr 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Mar 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Feb 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jan 2015 |███████████████∙∙∙∙∙|
        OUTPUT
      end

      describe "--unscaled" do
        let(:unscaled) { true }

        it "graphs activities on and after the specified date and does not scale graph" do
          stdout_only <<-OUTPUT
Nov 2015 |█
Oct 2015 |
Sep 2015 |
Aug 2015 |
Jul 2015 |
Jun 2015 |
May 2015 |
Apr 2015 |
Mar 2015 |
Feb 2015 |
Jan 2015 |███∙|
          OUTPUT
        end
      end
    end

    describe "--until" do
      subject { run_cmd("graph#{' --unscaled' if unscaled} --until 'January 6th 2015'") }

      it "graphs activities before and on the specified date and scales the graph" do
        stdout_only <<-OUTPUT
Jan 2015 |███████████████∙∙∙∙∙|
Dec 2014 |█████∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Nov 2014 |█████∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
        OUTPUT
      end

      describe "--unscaled" do
        let(:unscaled) { true }

        it "graphs activities before and on the specified date and does not scale graph" do
          stdout_only <<-OUTPUT
Jan 2015 |███∙|
Dec 2014 |█
Nov 2014 |█
          OUTPUT
        end
      end
    end

    describe "combining filters" do
      subject do
        run_cmd("graph#{' --unscaled' if unscaled} --since 'January 6th 2015' --with Grace")
      end

      it "only shows other activities within the same period as the filtered ones and scales the "\
         "graph" do
        # If we just rounded to the month, there would be three unfiltered activities in
        # January displayed (due to the one on 1/5/2015). Instead, we correctly display two.
        stdout_only <<-OUTPUT
Nov 2015 |█████∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Oct 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Sep 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Aug 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jul 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jun 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
May 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Apr 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Mar 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Feb 2015 |∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
Jan 2015 |█████∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙|
        OUTPUT
      end

      describe "--unscaled" do
        let(:unscaled) { true }

        it "only shows other activities within the same period as the filtered ones and does not "\
           "scale graph" do
          # If we just rounded to the month, there would be three unfiltered activities in
          # January displayed (due to the one on 1/5/2015). Instead, we correctly display two.
          stdout_only <<-OUTPUT
Nov 2015 |█
Oct 2015 |
Sep 2015 |
Aug 2015 |
Jul 2015 |
Jun 2015 |
May 2015 |
Apr 2015 |
Mar 2015 |
Feb 2015 |
Jan 2015 |█∙∙∙|
          OUTPUT
        end
      end
    end
  end
end
