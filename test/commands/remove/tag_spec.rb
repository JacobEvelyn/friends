# frozen_string_literal: true

require "./test/helper"

clean_describe "remove tag" do
  subject { run_cmd("remove tag #{friend_name} #{tag}") }

  let(:content) { CONTENT }

  describe "when friend name and tag are blank" do
    let(:friend_name) { nil }
    let(:tag) { nil }

    it "prints an error message" do
      stderr_only 'Error: No friend found for ""'
    end
  end

  describe "when friend name has no matches" do
    let(:friend_name) { "Garbage" }
    let(:tag) { "science" }

    it "prints an error message" do
      stderr_only 'Error: No friend found for "Garbage"'
    end
  end

  describe "when friend name has more than one match" do
    let(:friend_name) { "George" }
    let(:tag) { "science" }
    before { run_cmd("add friend George Harrison") }

    it "prints an error message" do
      stderr_only 'Error: More than one friend found for "George": '\
                  "George Harrison, George Washington Carver"
    end
  end

  describe "when friend name has one match" do
    let(:friend_name) { "Marie" }

    describe "when tag is not present on friend" do
      let(:tag) { "garbage" }
      it "prints an error message" do
        stderr_only 'Error: Tag "@garbage" not found for "Marie Curie"'
      end
    end

    describe "when tag is present on friend" do
      let(:tag) { "science" }

      it "removes tag from friend" do
        line_changed "- Marie Curie [Atlantis] @science",
                     "- Marie Curie [Atlantis]"
      end

      it "prints an output message" do
        stdout_only 'Tag removed from friend: "Marie Curie [Atlantis]"'
      end

      describe "when tag has colons and dashes" do
        let(:friend_name) { "Stanislav Petrov" }
        let(:tag) { "doesnt-trust-computers:military-uses" }

        it "removes tag from friend" do
          stdout_only 'Tag removed from friend: "Stanislav Petrov (a.k.a. Stan) '\
                      '@doesnt-trust-computers"'
        end
      end

      describe "when tag is passed with @" do
        let(:tag) { "@science" }

        it "adds tag to friend" do
          line_changed "- Marie Curie [Atlantis] @science", "- Marie Curie [Atlantis]"
        end

        it "prints an output message" do
          stdout_only 'Tag removed from friend: "Marie Curie [Atlantis]"'
        end
      end
    end
  end
end
