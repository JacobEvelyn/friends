# frozen_string_literal: true

require "./test/helper"

clean_describe "add nickname" do
  subject { run_cmd("add nickname #{friend_name} #{nickname}") }

  let(:content) { CONTENT }

  describe "when friend name has no matches" do
    let(:friend_name) { "Garbage" }
    let(:nickname) { "Georgie" }

    it "prints an error message" do
      stderr_only 'Error: No friend found for "Garbage"'
    end
  end

  describe "when friend name has more than one match" do
    let(:friend_name) { "George" }
    let(:nickname) { "Georgie" }
    before { run_cmd("add friend George Harrison") }

    it "prints an error message" do
      stderr_only 'Error: More than one friend found for "George": '\
                  "George Harrison, George Washington Carver"
    end
  end

  describe "when friend name has one match" do
    let(:friend_name) { "George" }

    describe "when nickname is blank" do
      let(:nickname) { "' '" }

      it "prints an error message" do
        stderr_only "Error: Nickname cannot be blank"
      end
    end

    describe "when nickname is not blank" do
      let(:nickname) { "Georgie" }

      it "adds nickname to friend" do
        line_changed "- George Washington Carver", "- George Washington Carver (a.k.a. Georgie)"
      end

      it "updates parenthetical in file when friend has existing nicknames" do
        run_cmd("add nickname #{friend_name} 'Mr. Peanut'")
        line_changed(
          "- George Washington Carver (a.k.a. Mr. Peanut)",
          "- George Washington Carver (a.k.a. Mr. Peanut a.k.a. Georgie)"
        )
      end

      it "prints an output message" do
        stdout_only 'Nickname added: "George Washington Carver (a.k.a. Georgie)"'
      end
    end
  end
end
