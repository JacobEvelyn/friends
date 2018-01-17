# frozen_string_literal: true

require "./test/helper"

clean_describe "rename location" do
  subject { run_cmd("rename location #{old_name} #{new_name}") }

  let(:content) { CONTENT }
  let(:new_name) { "'Ville Lumière'" }

  describe "when location name has no matches" do
    let(:old_name) { "Garbage" }
    it "prints an error message" do
      stderr_only 'Error: No location found for "Garbage"'
    end
  end

  describe "when location name has one match" do
    let(:old_name) { "Paris" }

    it "renames location" do
      line_changed("- Paris", "- Ville Lumière")
    end

    it "updates location name in activities" do
      line_changed(
        "- 2014-12-31: Celebrated the new year in _Paris_ with **Marie Curie**. @partying",
        "- 2014-12-31: Celebrated the new year in _Ville Lumière_ with **Marie Curie**. @partying"
      )
    end

    it "updates location name in notes" do
      line_changed(
        "- 2015-06-06: **Marie Curie** just got accepted into a PhD program in _Paris_. @school",
        "- 2015-06-06: **Marie Curie** just got accepted into a PhD program in "\
        "_Ville Lumière_. @school"
      )
    end

    it "updates location name for friends" do
      line_changed(
        "- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science",
        "- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Ville Lumière] @navy @science"
      )
    end

    it "prints an output message" do
      stdout_only 'Location renamed: "Ville Lumière"'
    end
  end
end
