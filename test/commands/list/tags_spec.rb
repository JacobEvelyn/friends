# frozen_string_literal: true

require "./test/helper"

clean_describe "list tags" do
  subject { run_cmd("list tags") }

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

    it "lists unique tags" do
      stdout_only <<-OUTPUT
@food
@navy
@partying
@school
@science
      OUTPUT
    end

    describe "--from activities" do
      subject { run_cmd("list tags --from activities") }

      it "lists unique tags from activities" do
        stdout_only <<-OUTPUT
@food
@partying
        OUTPUT
      end
    end

    describe "--from notes" do
      subject { run_cmd("list tags --from notes") }

      it "lists unique tags from notes" do
        stdout_only <<-OUTPUT
@navy
@school
        OUTPUT
      end
    end

    describe "--from friends" do
      subject { run_cmd("list tags --from friends") }

      it "lists unique tags from friends" do
        stdout_only <<-OUTPUT
@navy
@science
        OUTPUT
      end
    end

    describe "with more than one --from flag" do
      subject { run_cmd("list tags --from friends --from notes") }

      it "lists unique tags from friends and notes" do
        stdout_only <<-OUTPUT
@navy
@school
@science
        OUTPUT
      end
    end
  end
end
