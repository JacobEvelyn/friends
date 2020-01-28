# frozen_string_literal: true

require "./test/helper"

clean_describe "stats" do
  subject { run_cmd("stats") }

  describe "when file does not exist" do
    let(:content) { nil }

    it "returns the stats" do
      stdout_only <<-OUTPUT
Total activities: 0
Total friends: 0
Total locations: 0
Total notes: 0
Total tags: 0
Total time elapsed: 0 days
      OUTPUT
    end
  end

  describe "when the file is empty" do
    let(:content) { "" }

    it "returns the stats" do
      stdout_only <<-OUTPUT
Total activities: 0
Total friends: 0
Total locations: 0
Total notes: 0
Total tags: 0
Total time elapsed: 0 days
      OUTPUT
    end
  end

  describe "when file has stats" do
    let(:content) { CONTENT }

    it "returns the content" do
      stdout_only <<-OUTPUT
Total activities: 5
Total friends: 5
Total locations: 3
Total notes: 4
Total tags: 10
Total time elapsed: 1179 days
      OUTPUT
    end

    describe "when the file has a single note and no activities" do
      let(:content) do
        <<-FILE
### Notes:
- 2015-11-01: **Grace Hopper** just started a PhD program. @school @science
        FILE
      end

      it "counts elapsed days as 0" do
        stdout_only <<-OUTPUT
Total activities: 0
Total friends: 0
Total locations: 0
Total notes: 1
Total tags: 2
Total time elapsed: 0 days
        OUTPUT
      end
    end

    describe "when the file has a single activity and no notes" do
      let(:content) do
        <<-FILE
### Activities:
- 2015-11-01: **Grace Hopper** and I got lunch today.
        FILE
      end

      it "counts elapsed days as 0" do
        stdout_only <<-OUTPUT
Total activities: 1
Total friends: 0
Total locations: 0
Total notes: 0
Total tags: 0
Total time elapsed: 0 days
        OUTPUT
      end
    end

    describe "when the file has one activity and one note" do
      let(:content) do
        <<-FILE
### Activities:
- #{activity_date}: **Grace Hopper** and I got lunch today.

### Notes:
- #{note_date}: **Grace Hopper** just started a PhD program. @school @science
        FILE
      end

      describe "when the note and activity are on the same day" do
        let(:activity_date) { "2015-11-01" }
        let(:note_date) { activity_date }

        it "counts elapsed days as 0" do
          stdout_only <<-OUTPUT
Total activities: 1
Total friends: 0
Total locations: 0
Total notes: 1
Total tags: 2
Total time elapsed: 0 days
          OUTPUT
        end
      end

      describe "when the note and activity are one day apart" do
        let(:activity_date) { "2015-11-01" }
        let(:note_date) { "2015-11-02" }

        it "uses the singular for one elapsed day" do
          stdout_only <<-OUTPUT
Total activities: 1
Total friends: 0
Total locations: 0
Total notes: 1
Total tags: 2
Total time elapsed: 1 day
          OUTPUT
        end
      end
    end
  end
end
