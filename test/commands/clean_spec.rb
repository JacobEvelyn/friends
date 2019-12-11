# frozen_string_literal: true

require "./test/helper"

clean_describe "clean" do
  subject { run_cmd("#{quiet} clean") }
  let(:quiet) { nil }
  let(:content) { nil }

  it "outputs a message" do
    stdout_only "File cleaned: \"#{filename}\""
  end

  describe "when file does not exist" do
    let(:content) { nil }

    it "does not create the file" do
      value(File.exist?(filename)).must_equal false
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

  describe "when file is missing some headers and sections are out of order" do
    let(:content) do
      <<-CONTENT
### Friends:
- Marie Curie

### Activities:
- 2016-01-01: Celebrated the new year with **Marie Curie**.
      CONTENT
    end

    it "adds the missing file structure and reorders the sections" do
      file_equals <<-FILE
### Activities:
- 2016-01-01: Celebrated the new year with **Marie Curie**.

### Notes:

### Friends:
- Marie Curie

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

      describe "when the content includes friends and locations that have not yet been added" do
        let(:content) do
          <<-CONTENT
### Activities:
- 2017-01-01: Celebrated the new year in _Paris_ with **Marie Curie** and her husband **Pierre Curie**. **Marie Curie** loves _Paris_!
- 2016-12-31: Moved to _London_.

### Notes:
- 2017-01-01: I just learned that **Jacques Cousteau** is thinking about moving from _Gironde_ to _The Lost City of Atlantis_ (_Gironde_ did seem a bit too terrestrial for him).

### Friends:
- Grace Hopper [NYC]

### Locations:
- NYC
          CONTENT
        end

        it "adds those friends and locations" do
          file_equals <<-CONTENT
### Activities:
- 2017-01-01: Celebrated the new year in _Paris_ with **Marie Curie** and her husband **Pierre Curie**. **Marie Curie** loves _Paris_!
- 2016-12-31: Moved to _London_.

### Notes:
- 2017-01-01: I just learned that **Jacques Cousteau** is thinking about moving from _Gironde_ to _The Lost City of Atlantis_ (_Gironde_ did seem a bit too terrestrial for him).

### Friends:
- Grace Hopper [NYC]
- Jacques Cousteau
- Marie Curie
- Pierre Curie

### Locations:
- Gironde
- London
- NYC
- Paris
- The Lost City of Atlantis
          CONTENT
        end

        it "prints messages for both cleaning and adding friends/locations" do
          stdout_only <<-OUTPUT
Friend added: \"Marie Curie\"
Friend added: \"Pierre Curie\"
Location added: \"Paris\"
Location added: \"London\"
Friend added: \"Jacques Cousteau\"
Location added: \"Gironde\"
Location added: \"The Lost City of Atlantis\"
File cleaned: \"#{filename}\"
          OUTPUT
        end

        describe "when output is quieted" do
          let(:quiet) { "--quiet" }

          it "prints no messages" do
            stdout_only ""
          end
        end
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
