# frozen_string_literal: true

require "./test/helper"

clean_describe "set location" do
  subject { run_cmd("set location #{friend_name} #{location_name}") }
  let(:content) { CONTENT }

  describe "when friend does not exist" do
    let(:friend_name) { "Garbage" }
    let(:location_name) { "Paris" }

    it "prints an error message" do
      stderr_only 'Error: No friend found for "Garbage"'
    end
  end

  describe "when location does not exist" do
    let(:friend_name) { "Marie" }
    let(:location_name) { "Garbage" }

    it "prints an error message" do
      stderr_only 'Error: No location found for "Garbage"'
    end
  end

  describe "when friend and location exist" do
    let(:location_name) { "Paris" }

    describe "when friend already has a location" do
      let(:friend_name) { "Marie" }

      it "prints correct output" do
        stdout_only "Marie Curie's location set to: \"Paris\""
      end

      it "updates existing location" do
        line_changed "- Marie Curie [Atlantis] @science",
                     "- Marie Curie [Paris] @science"
      end
    end

    describe "when friend has no location" do
      let(:friend_name) { "George" }

      it "prints correct output" do
        stdout_only "George Washington Carver's location set to: \"Paris\""
      end

      it "adds a location" do
        line_changed "- George Washington Carver", "- George Washington Carver [Paris]"
      end
    end
  end
end
