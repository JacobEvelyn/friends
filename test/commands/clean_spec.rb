# frozen_string_literal: true

require "./test/helper"

clean_describe "clean" do
  subject { run_cmd("clean") }
  let(:content) { nil }

  it "outputs a message" do
    stdout_only "File cleaned: \"#{filename}\""
  end

  describe "when file does not exist" do
    let(:content) { nil }

    it "does not create the file" do
      File.exist?(filename).must_equal false
    end
  end

  describe "when file is empty" do
    let(:content) { "" }

    it "adds the file structure" do
      file_equals <<-FILE
### Activities:

### Notes:

### Friends:

### Locations:
      FILE
    end
  end

  describe "when file has content" do
    describe "when content is formatted correctly" do
      let(:content) { SCRAMBLED_CONTENT }

      it "writes the file with contents sorted" do
        file_equals CONTENT
      end
    end

    describe "when a header is malformed" do
      let(:content) do
        <<-FILE
### Activities:

### Garbage:

### Friends:

### Locations:
        FILE
      end

      it "prints an error message" do
        stderr_only 'Error: Expected "a valid header" on line 3'
      end
    end
  end
end
