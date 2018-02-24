# frozen_string_literal: true

require "./test/helper"

clean_describe "rename friend" do
  subject { run_cmd("rename friend #{old_name} #{new_name}") }

  let(:content) { CONTENT }
  let(:new_name) { "'George Washington'" }

  describe "when friend name has no matches" do
    let(:old_name) { "Garbage" }
    it "prints an error message" do
      stderr_only 'Error: No friend found for "Garbage"'
    end
  end

  describe "when friend name has more than one match" do
    let(:old_name) { "George" }
    before { run_cmd("add friend George Harrison") }

    it "prints an error message" do
      stderr_only 'Error: More than one friend found for "George": '\
                  "George Harrison, George Washington Carver"
    end
  end

  describe "when friend name has one match" do
    let(:old_name) { "George" }

    it "renames friend" do
      line_changed "- George Washington Carver", "- George Washington"
    end

    it "updates friend name in activities" do
      run_cmd("list activities")[:stdout].must_equal <<-FILE
2018-02-06: @science:indoors:agronomy-with-hydroponics: Norman Borlaug and George Washington Carver scored a tour of Atlantis' hydroponics gardens through wetplants@example.org and they took me along.
2015-11-01: Grace Hopper and I went to Marie's Diner. George had to cancel at the last minute. @food
2015-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
2014-12-31: Celebrated the new year in Paris with Marie Curie. @partying
2014-11-15: Talked to George Washington Carver on the phone for an hour.
      FILE
      subject
      run_cmd("list activities")[:stdout].must_equal <<-FILE
2018-02-06: @science:indoors:agronomy-with-hydroponics: Norman Borlaug and George Washington scored a tour of Atlantis' hydroponics gardens through wetplants@example.org and they took me along.
2015-11-01: Grace Hopper and I went to Marie's Diner. George had to cancel at the last minute. @food
2015-01-04: Got lunch with Grace Hopper and George Washington. @food
2014-12-31: Celebrated the new year in Paris with Marie Curie. @partying
2014-11-15: Talked to George Washington on the phone for an hour.
      FILE
    end

    it "updates friend name in notes" do
      line_changed(
        "- 2015-01-04: **Grace Hopper** and **George Washington Carver** both won an award.",
        "- 2015-01-04: **Grace Hopper** and **George Washington** both won an award."
      )
    end

    it "prints an output message" do
      stdout_only 'Name changed: "George Washington"'
    end
  end
end
