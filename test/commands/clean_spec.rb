# frozen_string_literal: true

require "./test/helper"

clean_describe "clean" do
  subject { run_cmd("clean") }

  it "outputs a message" do
    stdout_only "File cleaned: \"#{filename}\""
  end

  describe "when file does not exist" do
    it "does not create the file" do
      File.exist?(filename).must_equal false
    end
  end

  describe "when file is empty" do
    let(:content) { "" }

    it "adds the file structure" do
      file_equals <<-FILE
### Activities:

### Friends:

### Locations:
      FILE
    end
  end

  describe "when file has content" do
    let(:content) { SCRAMBLED_CONTENT }

    it "writes the file with contents sorted" do
      file_equals CONTENT
    end
  end
end
