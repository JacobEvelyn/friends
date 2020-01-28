# frozen_string_literal: true

require "./test/helper"

clean_describe "edit" do
  subject { run_cmd("#{quiet} edit", env_vars: "EDITOR=#{editor}") }

  let(:content) { SCRAMBLED_CONTENT }
  let(:editor) { "cat" }

  # First we test some simple behavior using `cat` as our "editor."
  describe "when output is quieted" do
    let(:quiet) { "--quiet" }

    it 'opens the file in the "editor"' do
      stdout_only content
    end

    it "cleans the file" do
      file_equals CONTENT # File is cleaned (no longer scrambled).
    end
  end

  describe "when output is not quieted" do
    let(:quiet) { nil }

    # Since our "editor" is just `cat`, our STDOUT output will include both the opening
    # message and the contents of the file.
    it 'prints a message and opens the file in the "editor"' do
      stdout_only "Opening \"#{filename}\" with \"#{editor}\""\
                  "\n#{content}File cleaned: \"#{filename}\""
    end

    it "cleans the file" do
      file_equals CONTENT # File is cleaned (no longer scrambled).
    end
  end

  describe "when editor does not exit successfully" do
    let(:editor) { "'exit 1 #'" }

    describe "when output is quieted" do
      let(:quiet) { "--quiet" }

      it "prints nothing to STDOUT" do
        stdout_only ""
      end

      it "does not clean the file" do
        file_equals content
      end
    end

    describe "when output is not quieted" do
      let(:quiet) { nil }

      it "prints a status message to STDOUT" do
        stdout_only <<-OUTPUT
Opening "#{filename}" with "exit 1 #"
Not cleaning file: "#{filename}" ("exit 1 #" did not exit successfully)
        OUTPUT
      end

      it "does not clean the file" do
        file_equals content
      end
    end
  end

  # Now we test a more realistic scenario, in which the editor actually modifies the
  # file. Instead of human interaction we use the `test/editor` file to serve as our
  # editor; that script adds a new activity to the file with a friend name and location
  # name that are not currently in the file. This tests the fact that `friends edit`
  # should clean the `friends.md` file *after* the editor has closed successfully.
  describe "when edit operation adds an event that includes a new friend or location" do
    let(:editor) { "test/editor" }
    let(:cleaned_edited_content) do
      <<-EXPECTED_CONTENT
### Activities:
- 2018-02-06: @science:indoors:agronomy-with-hydroponics: **Norman Borlaug** and **George Washington Carver** scored a tour of _Atlantis_' hydroponics gardens through wetplants@example.org and they took me along.
- 2015-11-01: **Grace Hopper** and I went to _Marie's Diner_. George had to cancel at the last minute.
- 2015-01-04: Got lunch with **Grace Hopper** and **George Washington Carver**. @food
- 2014-12-31: Celebrated the new year in _Paris_ with **Marie Curie**. @partying
- 2014-12-16: Okay, yep, I definitely just saw **Bigfoot** in the _Mysterious Mountains_!
- 2014-12-15: I just had a possible **Bigfoot** sighting! I think I may have seen **Bigfoot** in the _Mysterious Mountains_.
- 2014-11-15: Talked to **George Washington Carver** on the phone for an hour.

### Notes:
- 2017-03-12: **Marie Curie** completed her PhD in record time. @school
- 2015-06-15: **Grace Hopper** found out she's getting a big Naval Academy building named after her. @navy
- 2015-06-06: **Marie Curie** just got accepted into a PhD program in _Paris_. @school
- 2015-01-04: **Grace Hopper** and **George Washington Carver** both won an award.

### Friends:
- Bigfoot
- George Washington Carver
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science
- Marie Curie [Atlantis] @science
- Norman Borlaug (a.k.a. Norm) @science @science:outdoors @science:outdoors:agronomy
- Stanislav Petrov (a.k.a. Stan) @doesnt-trust-computers @doesnt-trust-computers:military-uses

### Locations:
- Atlantis
- Marie's Diner
- Mysterious Mountains
- Paris
      EXPECTED_CONTENT
    end

    describe "when output is quieted" do
      let(:quiet) { "--quiet" }

      it "prints nothing to STDOUT" do
        stdout_only ""
      end

      it "cleans the file after the editor has quit" do
        file_equals cleaned_edited_content
      end
    end

    describe "when output is not quieted" do
      let(:quiet) { nil }

      it "prints status messages to STDOUT" do
        stdout_only <<-OUTPUT
Opening "#{filename}" with "#{editor}"
Friend added: "Bigfoot"
Location added: "Mysterious Mountains"
File cleaned: "#{filename}"
        OUTPUT
      end

      it "cleans the file after the editor has quit" do
        file_equals cleaned_edited_content
      end
    end
  end
end
