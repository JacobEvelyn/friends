# frozen_string_literal: true

require "./test/helper"

clean_describe "remove alias" do
  subject { run_cmd("remove alias #{location_name} #{nickname}") }

  let(:content) { CONTENT }

  describe "when location and nickname are nil" do
    let(:location_name) { nil }
    let(:nickname) { nil }

    it "prints an error message" do
      stderr_only 'Error: Expected "[Location Name]" "[Alias]"'
    end
  end

  describe "when location name has no matches" do
    let(:location_name) { "Garbage" }
    let(:nickname) { "'Big Apple Pie'" }

    it "prints an error message" do
      stderr_only 'Error: No location found for "Garbage"'
    end
  end

  describe "when location name has one match" do
    let(:location_name) { "'New York City'" }

    describe "when alias is nil" do
      let(:nickname) { nil }
      it "prints an error message" do
        stderr_only "Error: Alias cannot be blank"
      end
    end

    describe "when alias is not present on location" do
      let(:nickname) { "Gotham" }
      it "prints an error message" do
        stderr_only 'Error: Alias "Gotham" not found for "New York City"'
      end
    end

    describe "when alias is present on location" do
      let(:nickname) { "'NYC'" }

      it "removes alias from location" do
        line_changed(
          "- New York City (a.k.a. NYC a.k.a. NY)",
          "- New York City (a.k.a. NY)"
        )
      end

      it "removes parenthetical from file when location has no more nicknames" do
        run_cmd("remove alias #{location_name} 'NY'")
        line_changed(
          "- New York City (a.k.a. NYC)",
          "- New York City"
        )
      end

      it "prints an output message" do
        stdout_only 'Alias removed: "New York City (a.k.a. NY)"'
      end
    end
  end
end
