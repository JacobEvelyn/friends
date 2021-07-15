# frozen_string_literal: true

require "./test/helper"

clean_describe "list locations" do
  subject { run_cmd("list locations") }

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

    it "lists locations in alphabetical" do
      stdout_only <<-OUTPUT
Atlantis
Martha's Vineyard
New York City
Paris
      OUTPUT
    end

    describe "--sort" do
      subject { run_cmd("list locations --sort #{sort} #{reverse}") }

      let(:reverse) { nil }

      # Use scrambled content to differentiate between output that is sorted and output that
      # only reads from the (usually-sorted) file.
      let(:content) { SCRAMBLED_CONTENT }

      describe "alphabetical" do
        let(:sort) { "alphabetical" }

        it "lists locations in sorted order" do
          stdout_only <<-OUTPUT
Atlantis
Martha's Vineyard
New York City
Paris
          OUTPUT
        end

        describe "--reverse" do
          let(:reverse) { "--reverse" }

          it "lists locations in reverse order" do
            stdout_only <<-OUTPUT
Paris
New York City
Martha's Vineyard
Atlantis
            OUTPUT
          end
        end
      end

      describe "n-activities" do
        let(:sort) { "n-activities" }

        it "lists locations in sorted order" do
          stdout_only <<-OUTPUT
1 activity: Paris
1 activity: Atlantis
1 activity: Martha's Vineyard
0 activities: New York City
          OUTPUT
        end

        describe "--reverse" do
          let(:reverse) { "--reverse" }

          it "lists locations in reverse order" do
            stdout_only <<-OUTPUT
0 activities: New York City
1 activity: Martha's Vineyard
1 activity: Atlantis
1 activity: Paris
            OUTPUT
          end
        end
      end

      describe "recency" do
        let(:sort) { "recency" }

        it "lists locations in sorted order" do
          stdout_only_regexes [
            "N/A days ago: New York City",
            /\d+ days ago: Atlantis/,
            /\d+ days ago: Martha's Vineyard/,
            /\d+ days ago: Paris/
          ]
        end

        describe "--reverse" do
          let(:reverse) { "--reverse" }

          it "lists locations in reverse order" do
            stdout_only_regexes [
              /\d+ days ago: Paris/,
              /\d+ days ago: Martha's Vineyard/,
              /\d+ days ago: Atlantis/,
              "N/A days ago: New York City"
            ]
          end
        end
      end
    end

    describe "--verbose" do
      subject { run_cmd("list locations --verbose") }

      it "lists locations in alphabetical order with details" do
        stdout_only <<-OUTPUT
Atlantis
Martha's Vineyard
New York City (a.k.a. NYC a.k.a. NY)
Paris
        OUTPUT
      end
    end
  end
end
