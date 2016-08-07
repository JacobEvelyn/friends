# frozen_string_literal: true

require "./test/helper"

clean_describe "list friends" do
  subject { run_cmd("list friends") }

  describe "when file does not exist" do
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

    it "lists friends in file order" do
      stdout_only <<-OUTPUT
George Washington Carver
Marie Curie
Grace Hopper
      OUTPUT
    end

    describe "--verbose" do
      subject { run_cmd("list friends --verbose") }

      it "lists friends in file order with details" do
        stdout_only <<-OUTPUT
George Washington Carver
Marie Curie [Atlantis] @science
Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science
        OUTPUT
      end
    end

    describe "--in" do
      subject { run_cmd("list friends --in #{location_name}") }

      describe "when location does not exist" do
        let(:location_name) { "Garbage" }
        it "prints an error message" do
          stderr_only 'Error: No location found for "Garbage"'
        end
      end

      describe "when location exists" do
        let(:location_name) { "paris" }
        it "matches location case-insensitively" do
          stdout_only "Grace Hopper"
        end
      end
    end

    describe "--tagged" do
      subject { run_cmd("list friends --tagged science") }

      it "matches tag case-sensitively" do
        stdout_only <<-OUTPUT
Marie Curie
Grace Hopper
        OUTPUT
      end
    end
  end
end
