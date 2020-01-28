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

    it "lists locations in file order" do
      stdout_only <<-OUTPUT
Paris
Atlantis
Marie's Diner
      OUTPUT
    end
  end
end
