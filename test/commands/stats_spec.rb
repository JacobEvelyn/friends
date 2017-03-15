# frozen_string_literal: true

require "./test/helper"

clean_describe "stats" do
  subject { run_cmd("stats") }

  describe "when file does not exist" do
    it "returns the stats" do
      stdout_only <<-FILE
Total activities: 0
Total friends: 0
Total time elapsed: 0 days
      FILE
    end
  end

  describe "when the file is empty" do
    let(:content) { "" }

    it "returns the stats" do
      stdout_only <<-FILE
Total activities: 0
Total friends: 0
Total time elapsed: 0 days
      FILE
    end
  end

  describe "when file has stats" do
    let(:content) { CONTENT }

    it "returns the content" do
      stdout_only <<-FILE
Total activities: 4
Total friends: 3
Total time elapsed: 351 days
      FILE
    end
  end
end
