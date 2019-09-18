# frozen_string_literal: true

def date_parsing_specs(test_stdout: true)
  describe "date parsing" do
    let(:description) { "Test." }

    describe "when date is in YYYY-MM-DD" do
      let(:date) { "2017-01-01" }

      it { line_added "- #{date}: #{description}" }
      it { stdout_only "#{capitalized_event} added: \"#{date}: #{description}\"" } if test_stdout
    end

    describe "when date is in MM-DD-YYYY" do
      let(:date) { "01-02-2017" }

      it { line_added "- 2017-01-02: #{description}" }
      it { stdout_only "#{capitalized_event} added: \"2017-01-02: #{description}\"" } if test_stdout
    end

    describe "when date is invalid" do
      let(:date) { "2017-02-30" }

      it { line_added "- 2017-03-02: #{description}" }
      it { stdout_only "#{capitalized_event} added: \"2017-03-02: #{description}\"" } if test_stdout
    end

    describe "when date is natural language and in full" do
      let(:date) { "February 23rd, 2017" }

      it { line_added "- 2017-02-23: #{description}" }
      it { stdout_only "#{capitalized_event} added: \"2017-02-23: #{description}\"" } if test_stdout
    end

    describe "when date is natural language and only month and day" do
      # We use two days rather than just one to avoid strange behavior around
      # edge cases when the test is being run right around midnight.
      let(:two_days_in_seconds) { 2 * 24 * 60 * 60 }
      let(:raw_date) { Time.now + two_days_in_seconds }
      let(:date) { raw_date.strftime("%B %d") }
      let(:expected_year) { raw_date.strftime("%Y").to_i - 1 }
      let(:expected_date_str) { "#{expected_year}-#{raw_date.strftime('%m-%d')}" }

      it { line_added "- #{expected_date_str}: #{description}" }
      if test_stdout
        it { stdout_only "#{capitalized_event} added: \"#{expected_date_str}: #{description}\"" }
      end
    end
  end
end

def description_parsing_specs(test_stdout: true)
  describe "description parsing" do
    let(:date) { Date.today.strftime }

    unless test_stdout
      describe "when description is blank" do
        let(:description) { "  " }

        it "prints an error message" do
          subject[:stderr].must_equal(
            ensure_trailing_newline_unless_empty("Error: Blank #{event} not added")
          )
        end
      end
    end

    describe "when description includes a friend's full name (case insensitive)" do
      let(:description) { "Lunch with grace hopper." }

      it { line_added "- #{date}: Lunch with **Grace Hopper**." }
      if test_stdout
        it { stdout_only "#{capitalized_event} added: \"#{date}: Lunch with Grace Hopper.\"" }
      end
    end

    describe "when description includes a friend's first name (case insensitive)" do
      let(:description) { "Lunch with grace." }

      it { line_added "- #{date}: Lunch with **Grace Hopper**." }
      if test_stdout
        it { stdout_only "#{capitalized_event} added: \"#{date}: Lunch with Grace Hopper.\"" }
      end
    end

    describe "when description has a friend's first name and last initial (case insensitive)" do
      describe "when followed by no period" do
        let(:description) { "Lunch with grace h" }

        it { line_added "- #{date}: Lunch with **Grace Hopper**" }
        if test_stdout
          it { stdout_only "#{capitalized_event} added: \"#{date}: Lunch with Grace Hopper\"" }
        end
      end

      describe "when followed by a period at the end of a sentence" do
        let(:description) { "Met grace h. So fun!" }

        it { line_added "- #{date}: Met **Grace Hopper**. So fun!" }
        if test_stdout
          it { stdout_only "#{capitalized_event} added: \"#{date}: Met Grace Hopper. So fun!\"" }
        end
      end

      describe "when followed by a period at the end of the description" do
        let(:description) { "Lunch with grace h." }

        it { line_added "- #{date}: Lunch with **Grace Hopper**." }
        if test_stdout
          it { stdout_only "#{capitalized_event} added: \"#{date}: Lunch with Grace Hopper.\"" }
        end
      end

      describe "when followed by a period in the middle of a sentence" do
        let(:description) { "Met grace h. at 12." }

        it { line_added "- #{date}: Met **Grace Hopper** at 12." }
        if test_stdout
          it { stdout_only "#{capitalized_event} added: \"#{date}: Met Grace Hopper at 12.\"" }
        end
      end
    end

    describe "when description includes a friend's nickname (case insensitive)" do
      let(:description) { "Lunch with the admiral." }

      it { line_added "- #{date}: Lunch with **Grace Hopper**." }
      if test_stdout
        it { stdout_only "#{capitalized_event} added: \"#{date}: Lunch with Grace Hopper.\"" }
      end
    end

    describe "when description includes a friend's nickname which contains a name" do
      let(:description) { "Lunch with Amazing Grace." }

      it { line_added "- #{date}: Lunch with **Grace Hopper**." }
      if test_stdout
        it { stdout_only "#{capitalized_event} added: \"#{date}: Lunch with Grace Hopper.\"" }
      end
    end

    describe "when description includes a friend's name at the beginning of a word" do
      # Capitalization reduces chance of a false positive.
      let(:description) { "Gracefully strolled." }

      it { line_added "- #{date}: Gracefully strolled." }
      if test_stdout
        it { stdout_only "#{capitalized_event} added: \"#{date}: Gracefully strolled.\"" }
      end
    end

    describe "when description includes a friend's name at the end of a word" do
      # Capitalization reduces chance of a false positive.
      let(:description) { "The service was a disGrace." }

      it { line_added "- #{date}: The service was a disGrace." }
      if test_stdout
        it { stdout_only "#{capitalized_event} added: \"#{date}: The service was a disGrace.\"" }
      end
    end

    describe "when description includes a friend's name in the middle of a word" do
      # Capitalization reduces chance of a false positive.
      let(:description) { "The service was disGraceful." }

      it { line_added "- #{date}: The service was disGraceful." }
      if test_stdout
        it { stdout_only "#{capitalized_event} added: \"#{date}: The service was disGraceful.\"" }
      end
    end

    describe "when a friend's name is escaped with a backslash" do
      # We have to use four backslashes here because of Ruby's backslash escaping; when this
      # goes through all of the layers of this test it emerges on the other side as a single one.
      let(:description) { "Dinner with \\\\Grace Kelly." }

      it { line_added "- #{date}: Dinner with Grace Kelly." }
      if test_stdout
        it { stdout_only "#{capitalized_event} added: \"#{date}: Dinner with Grace Kelly.\"" }
      end
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

### Notes:

### Friends:
- Mary Poppins
- Mary-Kate Olsen

### Locations:
FILE
        end

        it { line_added "- #{date}: Shopped w/ **Mary-Kate Olsen**." }
        if test_stdout
          it { stdout_only "#{capitalized_event} added: \"#{date}: Shopped w/ Mary-Kate Olsen.\"" }
        end
      end

      describe "when one name follows another after a hyphen" do
        let(:description) { "Shopped w/ Mary-Kate." }

        # Make sure "Kate" is a closer friend than "Mary-Kate" so we know our
        # test result isn't due to chance.
        let(:content) do
          <<-FILE
### Activities:
- 2017-01-01: Improv with **Kate Winslet**.

### Notes:

### Friends:
- Kate Winslet
- Mary-Kate Olsen

### Locations:
FILE
        end

        it { line_added "- #{date}: Shopped w/ **Mary-Kate Olsen**." }
        if test_stdout
          it { stdout_only "#{capitalized_event} added: \"#{date}: Shopped w/ Mary-Kate Olsen.\"" }
        end
      end

      describe "when one name is contained within another via hyphens" do
        let(:description) { "Met Mary-Jo-Kate." }

        # Make sure "Jo" is a closer friend than "Mary-Jo-Kate" so we know our
        # test result isn't due to chance.
        let(:content) do
          <<-FILE
### Activities:
- 2017-01-01: Singing with **Jo Stafford**.

### Notes:

### Friends:
- Jo Stafford
- Mary-Jo-Kate Olsen

### Locations:
FILE
        end

        it { line_added "- #{date}: Met **Mary-Jo-Kate Olsen**." }
        if test_stdout
          it { stdout_only "#{capitalized_event} added: \"#{date}: Met Mary-Jo-Kate Olsen.\"" }
        end
      end
    end

    describe "when a friend's first and middle name matches two other friends' first names" do
      let(:description) { "Met Martin Luther." }

      # Make sure "Martin Jones" and "Luther Jones" are closer friends than
      # "Martin Luther King" so we know our test result isn't due to chance.
      let(:content) do
        <<-FILE
### Activities:
- 2018-01-01: Singing with **Martin Jones**.
- 2018-01-01: Dancing with **Luther Jones**.

### Notes:

### Friends:
- Luther Jones
- Martin Jones
- Martin Luther King

### Locations:
FILE
      end

      it { line_added "- #{date}: Met **Martin Luther King**." }
      if test_stdout
        it { stdout_only "#{capitalized_event} added: \"#{date}: Met Martin Luther King.\"" }
      end
    end

    describe "when a friend has a first name only" do
      # We want to explicitly check that the first-name last-initial behavior
      # doesn't kick in here and match "Alejandra A" when the friend has no
      # last name.
      let(:description) { "Met Alejandra a few times." }

      let(:content) do
        <<-FILE
### Activities:

### Notes:

### Friends:
- Alejandra

### Locations:
FILE
      end

      it { line_added "- #{date}: Met **Alejandra** a few times." }
      if test_stdout
        it { stdout_only "#{capitalized_event} added: \"#{date}: Met Alejandra a few times.\"" }
      end
    end

    describe "when description has a friend's name with leading asterisks" do
      let(:description) { "Lunch with **Grace Hopper." }

      it { line_added "- #{date}: Lunch with **Grace Hopper." }
      if test_stdout
        it { stdout_only "#{capitalized_event} added: \"#{date}: Lunch with **Grace Hopper.\"" }
      end
    end

    describe "when description has a friend's name with trailing asterisks" do
      # Note: We can't guarantee that "Grace Hopper**" doesn't match because the "Grace" isn't
      # surrounded by asterisks.
      let(:description) { "Lunch with Grace**." }

      it { line_added "- #{date}: Lunch with Grace**." }
      if test_stdout
        it { stdout_only "#{capitalized_event} added: \"#{date}: Lunch with Grace**.\"" }
      end
    end

    describe "when description has a friend's name multiple times" do
      let(:description) { "Grace! Grace!!!" }

      it { line_added "- #{date}: **Grace Hopper**! **Grace Hopper**!!!" }
      if test_stdout
        it { stdout_only "#{capitalized_event} added: \"#{date}: Grace Hopper! Grace Hopper!!!\"" }
      end
    end

    describe "when description has a friend's full name which is another friend's first name" do
      let(:description) { "Hung out with Elizabeth for most of the day." }

      # Make sure "Elizabeth II" is a better friend than just "Elizabeth" to
      # ensure our result isn't due to chance.
      let(:content) do
        <<-FILE
### Activities:
- 2018-08-05: Royal picnic with **Elizabeth II**.

### Notes:

### Friends:
- Elizabeth
- Elizabeth II

### Locations:
FILE
      end

      it { line_added "- #{date}: Hung out with **Elizabeth** for most of the day." }
      if test_stdout
        it do
          stdout_only "#{capitalized_event} added: \"#{date}: "\
                      "Hung out with Elizabeth for most of the day.\""
        end
      end
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

### Notes:

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
          it do
            stdout_only "#{capitalized_event} added: "\
                        "\"#{date}: Met John Cage + Elizabeth Cady Stanton.\""
          end
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

### Notes:

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
          it do
            stdout_only "#{capitalized_event} added: "\
                        "\"#{date}: Dinner with John Cage and Elizabeth II.\""
          end
        end
      end
    end

    describe "when description contains a location name (case insensitive)" do
      let(:description) { "Lunch at a cafe in paris." }

      it { line_added "- #{date}: Lunch at a cafe in _Paris_." }
      if test_stdout
        it { stdout_only "#{capitalized_event} added: \"#{date}: Lunch at a cafe in Paris.\"" }
      end
    end

    describe "when description contains both names and locations" do
      let(:description) { "Grace and I went to Atlantis and then Paris for lunch with George." }

      it do
        line_added "- #{date}: **Grace Hopper** and I went to _Atlantis_ and then _Paris_ for "\
                   "lunch with **George Washington Carver**."
      end
      if test_stdout
        it do
          stdout_only "#{capitalized_event} added: \"#{date}: Grace Hopper and I went to "\
                      "Atlantis and then Paris for lunch with George Washington Carver.\""
        end
      end
    end
  end
end

def parsing_specs(event:)
  let(:event) { event.to_s }
  let(:capitalized_event) { event.to_s.capitalize }

  describe "when given a date and a description in the command" do
    subject { run_cmd("add #{event} #{date}: #{description}") }

    date_parsing_specs
    description_parsing_specs
  end

  describe "when given only a date in the command" do
    subject { run_cmd("add #{event} #{date}", stdin_data: description) }

    # We don't try to test the STDOUT here because our command prompt produces other STDOUT that's
    # hard to test.
    date_parsing_specs(test_stdout: false)
    description_parsing_specs(test_stdout: false)
  end

  describe "when given only a description in the command" do
    subject { run_cmd("add #{event} #{description}") }

    # We don't test date parsing since in this case the date is always inferred to be today.

    description_parsing_specs
  end

  describe "when given neither a date nor a description in the command" do
    subject { run_cmd("add #{event}", stdin_data: description) }

    # We don't test date parsing since in this case the date is always inferred to be today.

    # We don't try to test the STDOUT here because our command prompt produces other STDOUT that's
    # hard to test.
    description_parsing_specs(test_stdout: false)
  end
end
