# frozen_string_literal: true

require "date"

require "./test/helper"

def date_parsing_specs(test_stdout: true)
  describe "date parsing" do
    let(:description) { "Test." }

    describe "when date is in YYYY-MM-DD" do
      let(:date) { "2017-01-01" }

      it { line_added "- #{date}: #{description}" }
      it { stdout_only "Activity added: \"#{date}: #{description}\"" } if test_stdout
    end

    describe "when date is in MM-DD-YYYY" do
      let(:date) { "01-02-2017" }

      it { line_added "- 2017-01-02: #{description}" }
      it { stdout_only "Activity added: \"2017-01-02: #{description}\"" } if test_stdout
    end

    describe "when date is invalid" do
      let(:date) { "2017-02-30" }

      it { line_added "- 2017-03-02: #{description}" }
      it { stdout_only "Activity added: \"2017-03-02: #{description}\"" } if test_stdout
    end

    describe "when date is natural language and in full" do
      let(:date) { "February 23rd, 2017" }

      it { line_added "- 2017-02-23: #{description}" }
      it { stdout_only "Activity added: \"2017-02-23: #{description}\"" } if test_stdout
    end

    describe "when date is natural language and only month and day" do
      mocked_time = Time.new(2017, 8, 1) # First of August
      let(:date) { "February 23" }

      Time.stub :now, mocked_time do
        # Infers it means the last february not the next
        it { line_added "- 2017-02-23: #{description}" }
        it { stdout_only "Activity added: \"2017-02-23: #{description}\"" } if test_stdout
      end

      let(:date) { "23 February" }

      Time.stub :now, mocked_time do
        # Infers it means the last february not the next
        it { line_added "- 2017-02-23: #{description}" }
        it { stdout_only "Activity added: \"2017-02-23: #{description}\"" } if test_stdout
      end
    end
  end
end

def description_parsing_specs(test_stdout: true)
  describe "description parsing" do
    let(:date) { Date.today.strftime }

    describe "when description includes a friend's full name (case insensitive)" do
      let(:description) { "Lunch with grace hopper." }

      it { line_added "- #{date}: Lunch with **Grace Hopper**." }
      it { stdout_only "Activity added: \"#{date}: Lunch with Grace Hopper.\"" } if test_stdout
    end

    describe "when description includes a friend's first name (case insensitive)" do
      let(:description) { "Lunch with grace." }

      it { line_added "- #{date}: Lunch with **Grace Hopper**." }
      it { stdout_only "Activity added: \"#{date}: Lunch with Grace Hopper.\"" } if test_stdout
    end

    describe "when description has a friend's first name and last initial (case insensitive)" do
      describe "when followed by no period" do
        let(:description) { "Lunch with grace h" }

        it { line_added "- #{date}: Lunch with **Grace Hopper**" }
        it { stdout_only "Activity added: \"#{date}: Lunch with Grace Hopper\"" } if test_stdout
      end

      describe "when followed by a period at the end of a sentence" do
        let(:description) { "Met grace h. So fun!" }

        it { line_added "- #{date}: Met **Grace Hopper**. So fun!" }
        it { stdout_only "Activity added: \"#{date}: Met Grace Hopper. So fun!\"" } if test_stdout
      end

      describe "when followed by a period at the end of the description" do
        let(:description) { "Lunch with grace h." }

        it { line_added "- #{date}: Lunch with **Grace Hopper**." }
        it { stdout_only "Activity added: \"#{date}: Lunch with Grace Hopper.\"" } if test_stdout
      end

      describe "when followed by a period in the middle of a sentence" do
        let(:description) { "Met grace h. at 12." }

        it { line_added "- #{date}: Met **Grace Hopper** at 12." }
        it { stdout_only "Activity added: \"#{date}: Met Grace Hopper at 12.\"" } if test_stdout
      end
    end

    describe "when description includes a friend's nickname (case insensitive)" do
      let(:description) { "Lunch with the admiral." }

      it { line_added "- #{date}: Lunch with **Grace Hopper**." }
      it { stdout_only "Activity added: \"#{date}: Lunch with Grace Hopper.\"" } if test_stdout
    end

    describe "when description includes a friend's nickname which contains a name" do
      let(:description) { "Lunch with Amazing Grace." }

      it { line_added "- #{date}: Lunch with **Grace Hopper**." }
      it { stdout_only "Activity added: \"#{date}: Lunch with Grace Hopper.\"" } if test_stdout
    end

    describe "when description includes a friend's name at the beginning of a word" do
      # Capitalization reduces chance of a false positive.
      let(:description) { "Gracefully strolled." }

      it { line_added "- #{date}: Gracefully strolled." }
      it { stdout_only "Activity added: \"#{date}: Gracefully strolled.\"" } if test_stdout
    end

    describe "when description includes a friend's name at the end of a word" do
      # Capitalization reduces chance of a false positive.
      let(:description) { "The service was a disGrace." }

      it { line_added "- #{date}: The service was a disGrace." }
      it { stdout_only "Activity added: \"#{date}: The service was a disGrace.\"" } if test_stdout
    end

    describe "when description includes a friend's name in the middle of a word" do
      # Capitalization reduces chance of a false positive.
      let(:description) { "The service was disGraceful." }

      it { line_added "- #{date}: The service was disGraceful." }
      it { stdout_only "Activity added: \"#{date}: The service was disGraceful.\"" } if test_stdout
    end

    describe "when a friend's name is escaped with a backslash" do
      # We have to use four backslashes here because of Ruby's backslash escaping; when this
      # goes through all of the layers of this test it emerges on the other side as a single one.
      let(:description) { "Dinner with \\\\Grace Kelly." }

      it { line_added "- #{date}: Dinner with Grace Kelly." }
      it { stdout_only "Activity added: \"#{date}: Dinner with Grace Kelly.\"" } if test_stdout
    end

    describe "hyphenated name edge cases" do
      describe "when one name precedes another before a hyphen" do
        let(:description) { "Shopped w/ Mary-Kate." }

        # Make sure "Mary" is a closer friend than "Mary-Kate" so we know our
        # test result isn't due to chance.
        let(:content) do
          <<-FILE
### Activities:
- 2017-01-01: Singing with **Mary Poppins**.

### Friends:
- Mary Poppins
- Mary-Kate Olsen

### Locations:
FILE
        end

        it { line_added "- #{date}: Shopped w/ **Mary-Kate Olsen**." }
        it { stdout_only "Activity added: \"#{date}: Shopped w/ Mary-Kate Olsen.\"" } if test_stdout
      end

      describe "when one name follows another after a hyphen" do
        let(:description) { "Shopped w/ Mary-Kate." }

        # Make sure "Kate" is a closer friend than "Mary-Kate" so we know our
        # test result isn't due to chance.
        let(:content) do
          <<-FILE
### Activities:
- 2017-01-01: Improv with **Kate Winslet**.

### Friends:
- Kate Winslet
- Mary-Kate Olsen

### Locations:
FILE
        end

        it { line_added "- #{date}: Shopped w/ **Mary-Kate Olsen**." }
        it { stdout_only "Activity added: \"#{date}: Shopped w/ Mary-Kate Olsen.\"" } if test_stdout
      end

      describe "when one name is contained within another via hyphens" do
        let(:description) { "Met Mary-Jo-Kate." }

        # Make sure "Jo" is a closer friend than "Mary-Jo-Kate" so we know our
        # test result isn't due to chance.
        let(:content) do
          <<-FILE
### Activities:
- 2017-01-01: Singing with **Jo Stafford**.

### Friends:
- Jo Stafford
- Mary-Jo-Kate Olsen

### Locations:
FILE
        end

        it { line_added "- #{date}: Met **Mary-Jo-Kate Olsen**." }
        it { stdout_only "Activity added: \"#{date}: Met Mary-Jo-Kate Olsen.\"" } if test_stdout
      end
    end

    describe "when description has a friend's name with leading asterisks" do
      let(:description) { "Lunch with **Grace Hopper." }

      it { line_added "- #{date}: Lunch with **Grace Hopper." }
      it { stdout_only "Activity added: \"#{date}: Lunch with **Grace Hopper.\"" } if test_stdout
    end

    describe "when description has a friend's name with trailing asterisks" do
      # Note: We can't guarantee that "Grace Hopper**" doesn't match because the "Grace" isn't
      # surrounded by asterisks.
      let(:description) { "Lunch with Grace**." }

      it { line_added "- #{date}: Lunch with Grace**." }
      it { stdout_only "Activity added: \"#{date}: Lunch with Grace**.\"" } if test_stdout
    end

    describe "when description has a friend's name multiple times" do
      let(:description) { "Grace! Grace!!!" }

      it { line_added "- #{date}: **Grace Hopper**! **Grace Hopper**!!!" }
      it { stdout_only "Activity added: \"#{date}: Grace Hopper! Grace Hopper!!!\"" } if test_stdout
    end

    describe "when description has a name with multiple friend matches" do
      describe "when there is useful context from past activities" do
        let(:description) { "Met John + Elizabeth." }

        # Create a past activity in which Elizabeth Cady Stanton did something
        # with John Cage. Then, create past activities to make Elizabeth II a
        # better friend than Elizabeth Cady Stanton.
        let(:content) do
          <<-FILE
### Activities:
- 2017-01-05: Picnic with **Elizabeth Cady Stanton** and **John Cage**.
- 2017-01-04: Got lunch with **Elizabeth II**.
- 2017-01-03: Ice skated with **Elizabeth II**.

### Friends:
- Elizabeth Cady Stanton
- Elizabeth II
- John Cage

### Locations:
FILE
        end

        # Elizabeth II is the better friend, but historical activities have
        # had Elizabeth Cady Stanton and John Cage together. Thus, we should
        # interpret "Elizabeth" as Elizabeth Cady Stanton.
        it { line_added "- #{date}: Met **John Cage** + **Elizabeth Cady Stanton**." }
        if test_stdout
          it { stdout_only "Activity added: \"#{date}: Met John Cage + Elizabeth Cady Stanton.\"" }
        end
      end

      describe "when there is no useful context from past activities" do
        let(:description) { "Dinner with John and Elizabeth." }

        # Create a past activity in which Elizabeth Cady Stanton did something
        # with John Cage. Then, create past activities to make Elizabeth II a
        # better friend than Elizabeth Cady Stanton.
        let(:content) do
          <<-FILE
### Activities:
- 2017-01-03: Ice skated with **Elizabeth II**.

### Friends:
- Elizabeth Cady Stanton
- Elizabeth II
- John Cage

### Locations:
FILE
        end

        # Pick the "Elizabeth" with more activities.
        it { line_added "- #{date}: Dinner with **John Cage** and **Elizabeth II**." }
        if test_stdout
          it { stdout_only "Activity added: \"#{date}: Dinner with John Cage and Elizabeth II.\"" }
        end
      end
    end

    describe "when description contains a location name (case insensitive)" do
      let(:description) { "Lunch at a cafe in paris." }

      it { line_added "- #{date}: Lunch at a cafe in _Paris_." }
      it { stdout_only "Activity added: \"#{date}: Lunch at a cafe in Paris.\"" } if test_stdout
    end

    describe "when description contains both names and locations" do
      let(:description) { "Grace and I went to Atlantis and then Paris for lunch with George." }

      it do
        line_added "- #{date}: **Grace Hopper** and I went to _Atlantis_ and then _Paris_ for "\
                   "lunch with **George Washington Carver**."
      end
      if test_stdout
        it do
          stdout_only "Activity added: \"#{date}: Grace Hopper and I went to Atlantis and then "\
                      "Paris for lunch with George Washington Carver.\""
        end
      end
    end
  end
end

clean_describe "add activity" do
  let(:content) { CONTENT }

  describe "date ordering" do
    let(:content) do
      <<-FILE
### Activities:
- 2017-01-01: Activity 1.

### Friends:

### Locations:
FILE
    end

    subject do
      run_cmd("add activity 2017-01-01: Activity 2.")
      run_cmd("add activity 2017-01-01: Activity 3.")
      run_cmd("add activity 2017-01-01: Activity 4.")
    end

    it "orders dates by insertion time" do
      subject
      File.read(filename).must_equal <<-FILE
### Activities:
- 2017-01-01: Activity 4.
- 2017-01-01: Activity 3.
- 2017-01-01: Activity 2.
- 2017-01-01: Activity 1.

### Friends:

### Locations:
FILE
    end
  end

  describe "when given a date and a description in the command" do
    subject { run_cmd("add activity #{date}: #{description}") }

    date_parsing_specs
    description_parsing_specs
  end

  describe "when given only a date in the command" do
    subject { run_cmd("add activity #{date}", stdin_data: description) }

    # We don't try to test the STDOUT here because our command prompt produces other STDOUT that's
    # hard to test.
    date_parsing_specs(test_stdout: false)
    description_parsing_specs(test_stdout: false)
  end

  describe "when given only a description in the command" do
    subject { run_cmd("add activity #{description}") }

    # We don't test date parsing since in this case the date is always inferred to be today.

    description_parsing_specs
  end

  describe "when given neither a date nor a description in the command" do
    subject { run_cmd("add activity", stdin_data: description) }

    # We don't test date parsing since in this case the date is always inferred to be today.

    # We don't try to test the STDOUT here because our command prompt produces other STDOUT that's
    # hard to test.
    description_parsing_specs(test_stdout: false)
  end
end
