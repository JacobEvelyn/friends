# frozen_string_literal: true

require "./test/helper"

clean_describe "add friend" do
  subject { run_cmd("add friend #{friend_name}") }

  let(:content) { CONTENT }

  describe "when there is an existing friend with that name" do
    let(:friend_name) { "George Washington Carver" }

    it "prints an error message" do
      stderr_only 'Error: Friend named "George Washington Carver" already exists'
    end
  end

  describe "when there is no existing friend with that name" do
    # This also tests that we can use multi-word names without quotes.
    let(:friend_name) { "George Washington" }

    it "adds friend" do
      line_added "- George Washington"
    end

    it "prints an output message" do
      stdout_only 'Friend added: "George Washington"'
    end
  end
end
