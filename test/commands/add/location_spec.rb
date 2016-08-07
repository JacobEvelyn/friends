# frozen_string_literal: true

require "./test/helper"

clean_describe "add location" do
  subject { run_cmd("add location #{location_name}") }

  let(:content) { CONTENT }

  describe "when there is an existing location with that name" do
    let(:location_name) { "Paris" }

    it "prints an error message" do
      stderr_only 'Error: Location "Paris" already exists'
    end
  end

  describe "when there is no existing location with that name" do
    # This also tests that we can use multi-word names without quotes.
    let(:location_name) { "New England" }

    it "adds location" do
      line_added "- New England"
    end

    it "prints an output message" do
      stdout_only 'Location added: "New England"'
    end
  end
end
