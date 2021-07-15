# frozen_string_literal: true

require "./test/helper"

clean_describe "list friends" do
  subject { run_cmd("list friends") }

  describe "when file does not exist" do
    let(:content) { nil }

    it "does not list anything" do
      stdout_only ""
    end
  end

  describe "when file is empty" do
    let(:content) { "" }

    it "does not list anything" do
      stdout_only ""
    end
  end

  describe "when file has content" do
    # Use scrambled content to differentiate between output that is sorted and output that
    # only reads from the (usually-sorted) file.
    let(:content) { SCRAMBLED_CONTENT }

    it "lists friends in alphabetical order" do
      stdout_only <<-OUTPUT
George Washington Carver
Grace Hopper
Marie Curie
Norman Borlaug
Stanislav Petrov
      OUTPUT
    end

    describe "--verbose" do
      subject { run_cmd("list friends --verbose") }

      it "lists friends in sorted order with details" do
        stdout_only <<-OUTPUT
George Washington Carver
Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science
Marie Curie [Atlantis] @science
Norman Borlaug (a.k.a. Norm) @science @science:outdoors @science:outdoors:agronomy
Stanislav Petrov (a.k.a. Stan) @doesnt-trust-computers @doesnt-trust-computers:military-uses
        OUTPUT
      end
    end

    describe "--in" do
      subject { run_cmd("list friends --in #{location_name}") }

      describe "when location does not exist" do
        let(:location_name) { "Garbage" }
        it "prints an error message" do
          stderr_only 'Error: No location found for "Garbage"'
        end
      end

      describe "when location exists" do
        let(:location_name) { "paris" }
        it "matches location case-insensitively" do
          stdout_only "Grace Hopper"
        end
      end
    end

    describe "--tagged" do
      subject { run_cmd("list friends --tagged scIence") }

      it "matches tag case-insensitively" do
        stdout_only <<-OUTPUT
Grace Hopper
Marie Curie
Norman Borlaug
        OUTPUT
      end

      describe "when more than one tag is passed" do
        subject { run_cmd("list friends --tagged #{tag1} --tagged #{tag2}") }
        let(:tag1) { "Science" }
        let(:tag2) { "NAVY" }
        let(:content) do
          <<-FILE
### Activities:

### Friends:
- George Washington Carver
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science
- Marie Curie [Atlantis] @science
- Neil Armstrong @navy @science
- John F. Kennedy @navy
FILE
        end

        it "matches all tags case-insensitively" do
          stdout_only <<-OUTPUT
Grace Hopper
Neil Armstrong
        OUTPUT
        end
      end

      describe "when a tag is passed with colons and dashes" do
        subject { run_cmd("list friends --tagged doesnt-trust-computers:military-uses") }

        it "matches tag" do
          stdout_only <<-OUTPUT
Stanislav Petrov
          OUTPUT
        end
      end
    end

    describe "--sort" do
      subject { run_cmd("list friends --sort #{sort} #{reverse}") }

      let(:reverse) { nil }

      # Use scrambled content to differentiate between output that is sorted and output that
      # only reads from the (usually-sorted) file.
      let(:content) { SCRAMBLED_CONTENT }

      describe "alphabetical" do
        let(:sort) { "alphabetical" }

        it "lists friends in sorted order" do
          stdout_only <<-OUTPUT
George Washington Carver
Grace Hopper
Marie Curie
Norman Borlaug
Stanislav Petrov
          OUTPUT
        end

        describe "--reverse" do
          let(:reverse) { "--reverse" }

          it "lists friends in reverse order" do
            stdout_only <<-OUTPUT
Stanislav Petrov
Norman Borlaug
Marie Curie
Grace Hopper
George Washington Carver
            OUTPUT
          end
        end
      end

      describe "n-activities" do
        let(:sort) { "n-activities" }

        it "lists friends in sorted order" do
          stdout_only <<-OUTPUT
3 activities: George Washington Carver
2 activities: Grace Hopper
1 activity: Marie Curie
1 activity: Norman Borlaug
0 activities: Stanislav Petrov
          OUTPUT
        end

        describe "--reverse" do
          let(:reverse) { "--reverse" }

          it "lists friends in reverse order" do
            stdout_only <<-OUTPUT
0 activities: Stanislav Petrov
1 activity: Norman Borlaug
1 activity: Marie Curie
2 activities: Grace Hopper
3 activities: George Washington Carver
            OUTPUT
          end
        end
      end

      describe "recency" do
        let(:sort) { "recency" }

        it "lists friends in sorted order" do
          stdout_only_regexes [
            "N/A days ago: Stanislav Petrov",
            /\d+ days ago: George Washington Carver/,
            /\d+ days ago: Norman Borlaug/,
            /\d+ days ago: Grace Hopper/,
            /\d+ days ago: Marie Curie/
          ]
        end

        describe "--reverse" do
          let(:reverse) { "--reverse" }

          it "lists friends in reverse order" do
            stdout_only_regexes [
              /\d+ days ago: Marie Curie/,
              /\d+ days ago: Grace Hopper/,
              /\d+ days ago: Norman Borlaug/,
              /\d+ days ago: George Washington Carver/,
              "N/A days ago: Stanislav Petrov"
            ]
          end
        end
      end
    end
  end
end
