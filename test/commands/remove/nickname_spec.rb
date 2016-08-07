# frozen_string_literal: true

require "./test/helper"

clean_describe "remove nickname" do
  subject { run_cmd("remove nickname #{friend_name} #{nickname}") }

  let(:content) { CONTENT }

  describe "when friend name has no matches" do
    let(:friend_name) { "Garbage" }
    let(:nickname) { "'Amazing Grace'" }

    it "prints an error message" do
      stderr_only 'Error: No friend found for "Garbage"'
    end
  end

  describe "when friend name has more than one match" do
    let(:friend_name) { "George" }
    let(:nickname) { "'Amazing Grace'" }
    before { run_cmd("add friend George Harrison") }

    it "prints an error message" do
      stderr_only 'Error: More than one friend found for "George": '\
                  "George Harrison, George Washington Carver"
    end
  end

  describe "when friend name has one match" do
    let(:friend_name) { "Grace" }

    describe "when nickname is not present on friend" do
      let(:nickname) { "Gracie" }
      it "prints an error message" do
        stderr_only 'Error: Nickname "Gracie" not found for "Grace Hopper"'
      end
    end

    describe "when nickname is present on friend" do
      let(:nickname) { "'Amazing Grace'" }

      it "removes nickname from friend" do
        line_changed(
          "- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science",
          "- Grace Hopper (a.k.a. The Admiral) [Paris] @navy @science"
        )
      end

      it "removes parenthetical from file when friend has no more nicknames" do
        run_cmd("remove nickname #{friend_name} 'The Admiral'")
        line_changed(
          "- Grace Hopper (a.k.a. Amazing Grace) [Paris] @navy @science",
          "- Grace Hopper [Paris] @navy @science"
        )
      end

      it "prints an output message" do
        stdout_only 'Nickname removed: "Grace Hopper (a.k.a. The Admiral) [Paris] @navy @science"'
      end
    end
  end
end
