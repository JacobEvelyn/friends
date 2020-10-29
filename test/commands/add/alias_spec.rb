# frozen_string_literal: true

require "./test/helper"

clean_describe "add alias" do
  subject { run_cmd("add alias #{location_name} #{nickname}") }

  let(:content) { CONTENT }

  describe "when location name and alias are blank" do
    let(:location_name) { nil }
    let(:nickname) { nil }

    it "prints an error message" do
      stderr_only 'Error: Expected "[Location Name]" "[Alias]"'
    end
  end

  describe "when location name has no matches" do
    let(:location_name) { "Garbage" }
    let(:nickname) { "Big Apple Pie" }

    it "prints an error message" do
      stderr_only 'Error: No location found for "Garbage"'
    end
  end

  describe "when location alias has more than one match" do
    let(:location_name) { "'New York City'" }
    let(:nickname) { "'Big Apple'" }
    before do
      run_cmd("add location Manhattan")
      run_cmd("add alias Manhattan 'Big Apple'")
    end

    it "prints an error message" do
      stderr_only "Error: The location alias "\
                  '"Big Apple" is already taken by "Manhattan (a.k.a. Big Apple)"'
    end
  end

  describe "when location name has one match" do
    let(:location_name) { "'New York City'" }

    describe "when alias is blank" do
      let(:nickname) { "' '" }

      it "prints an error message" do
        stderr_only "Error: Alias cannot be blank"
      end
    end

    describe "when alias is nil" do
      let(:nickname) { nil }

      it "prints an error message" do
        stderr_only "Error: Alias cannot be blank"
      end
    end

    describe "when alias is not blank" do
      let(:nickname) { "'Big Apple'" }

      it "adds alias to location" do
        line_changed "- New York City (a.k.a. NYC a.k.a. NY)",
                     "- New York City (a.k.a. NYC a.k.a. NY a.k.a. Big Apple)"
      end

      it "prints an output message" do
        stdout_only 'Alias added: "New York City (a.k.a. NYC a.k.a. NY a.k.a. Big Apple)"'
      end
    end
  end
end
