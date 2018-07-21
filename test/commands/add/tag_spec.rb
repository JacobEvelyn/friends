# frozen_string_literal: true

require "./test/helper"

clean_describe "add tag" do
  subject { run_cmd("add tag #{friend_name} #{tag}") }

  let(:content) { CONTENT }

  describe "when friend name has no matches" do
    let(:friend_name) { "Garbage" }
    let(:tag) { "school" }

    it "prints an error message" do
      stderr_only 'Error: No friend found for "Garbage"'
    end
  end

  describe "when friend name has more than one match" do
    let(:friend_name) { "George" }
    let(:tag) { "school" }
    before { run_cmd("add friend George Harrison") }

    it "prints an error message" do
      stderr_only 'Error: More than one friend found for "George": '\
                  "George Harrison, George Washington Carver"
    end
  end

  describe "when friend name has one match" do
    let(:friend_name) { "George" }

    describe "when tag is blank" do
      let(:tag) { "' '" }

      it "prints an error message" do
        stderr_only "Error: Tag cannot be blank"
      end
    end

    describe "when tag is blank with an @" do
      let(:tag) { "'@ '" }

      it "prints an error message" do
        stderr_only "Error: Tag cannot be blank"
      end
    end

    describe "when tag is not blank" do
      let(:tag) { "school:tuskegee-institute" }

      it "adds tag to friend" do
        line_changed(
          "- George Washington Carver",
          "- George Washington Carver @school:tuskegee-institute"
        )
      end

      it "prints an output message" do
        stdout_only 'Tag added to friend: "George Washington Carver @school:tuskegee-institute"'
      end

      describe "when tag is passed with @" do
        let(:tag) { "@school:tuskegee-institute" }

        it "adds tag to friend" do
          line_changed(
            "- George Washington Carver",
            "- George Washington Carver @school:tuskegee-institute"
          )
        end

        it "prints an output message" do
          stdout_only 'Tag added to friend: "George Washington Carver @school:tuskegee-institute"'
        end
      end

      describe "when friend already has tags" do
        let(:friend_name) { "Marie" }
        let(:tag) { "school:ecole-normale-superieure" }

        it "allows for multiple tags" do
          line_changed(
            "- Marie Curie [Atlantis] @science",
            "- Marie Curie [Atlantis] @science @school:ecole-normale-superieure"
          )
        end
      end
    end
  end
end
