require "./test/helper"

describe Friends::Activity do
  let(:date) { Date.today - 1 }
  let(:date_s) { date.to_s }
  let(:friend1) { Friends::Friend.new(name: "Elizabeth Cady Stanton") }
  let(:friend2) { Friends::Friend.new(name: "John Cage") }
  let(:description) do
    "Lunch with **#{friend1.name}** and **#{friend2.name}** on _The Moon_ "\
    "after hanging out in _Atlantis_."
  end
  let(:partition) { Friends::Activity::DATE_PARTITION }
  let(:activity) do
    Friends::Activity.new(str: "#{date_s}#{partition}#{description}")
  end

  describe ".deserialize" do
    subject { Friends::Activity.deserialize(serialized_str) }

    describe "when serialized string is empty" do
      let(:serialized_str) { "" }

      it "defaults date to today and sets no description" do
        today = Date.today - 7

        # We stub out Date.today to guarantee that it is always the same even
        # when the date changes in the middle of the test's execution. To ensure
        # this technique actually works, we move our reference time backward by
        # a week.
        Date.stub(:today, today) do
          new_activity = subject
          new_activity.date.must_equal today
          new_activity.description.must_equal ""
        end
      end
    end

    describe "when string is well-formed" do
      let(:serialized_str) { "#{date_s}: #{description}" }

      it "creates an activity with the correct date and description" do
        new_activity = subject
        new_activity.date.must_equal date
        new_activity.description.must_equal description
      end
    end

    describe "when date is written in natural language" do
      let(:serialized_str) { "Yesterday: #{description}" }

      it "creates an activity with the correct date and description" do
        now = Time.now + 604800

        # Chronic uses Time.now for parsing, so we stub this to prevent racy
        # behavior when the date changes in the middle of test execution. To
        # ensure this technique actually works, we move our reference time
        # backward by a week.
        Time.stub(:now, now) do
          new_activity = subject
          new_activity.date.must_equal (now.to_date - 1)
          new_activity.description.must_equal description
        end
      end
    end

    describe "when no date is present" do
      let(:serialized_str) { description }

      it "defaults to today" do
        today = Date.today - 7

        # We stub out Date.today to guarantee that it is always the same even
        # when the date changes in the middle of the test's execution. To ensure
        # this technique actually works, we move our reference time backward by
        # a week.
        Date.stub(:today, today) { subject.date.must_equal today }
      end
    end

    describe "when no description is present" do
      let(:serialized_str) { date_s }

      it "leaves description blank" do
        new_activity = subject
        new_activity.date.must_equal date
        new_activity.description.must_equal ""
      end
    end
  end

  describe "#new" do
    subject { activity }

    it { subject.date.must_equal date }
    it { subject.description.must_equal description }
  end

  describe "#display_text" do
    subject { activity.display_text }

    it do
      subject.
        must_equal "#{Paint[date_s, :bold]}: "\
          "Lunch with #{Paint[friend1.name, :bold, :magenta]} and "\
          "#{Paint[friend2.name, :bold, :magenta]} on "\
          "#{Paint['The Moon', :bold, :yellow]} after hanging out in "\
          "#{Paint['Atlantis', :bold, :yellow]}."
    end
  end

  describe "#serialize" do
    subject { activity.serialize }

    it do
      subject.
        must_equal "#{Friends::Activity::SERIALIZATION_PREFIX}#{date_s}: "\
          "#{description}"
    end
  end

  describe "#highlight_description" do
    # Add helpers to set internal states for friends and activities.
    def stub_friends(val)
      old_val = introvert.instance_variable_get(:@friends)
      introvert.instance_variable_set(:@friends, val)
      yield
      introvert.instance_variable_set(:@friends, old_val)
    end

    def stub_activities(val)
      old_val = introvert.instance_variable_get(:@activities)
      introvert.instance_variable_set(:@activities, val)
      yield
      introvert.instance_variable_set(:@activities, old_val)
    end

    def stub_locations(val)
      old_val = introvert.instance_variable_get(:@locations)
      introvert.instance_variable_set(:@locations, val)
      yield
      introvert.instance_variable_set(:@locations, old_val)
    end

    let(:locations) do
      [
        Friends::Location.new(name: "Atlantis"),
        Friends::Location.new(name: "The Moon")
      ]
    end
    let(:friends) { [friend1, friend2] }
    let(:introvert) { Friends::Introvert.new }
    subject do
      stub_friends(friends) do
        stub_locations(locations) do
          activity.highlight_description(introvert: introvert)
        end
      end
    end

    it "finds all friends and locations" do
      subject
      activity.description.must_equal "Lunch with **#{friend1.name}** and "\
                                      "**#{friend2.name}** on _The Moon_ "\
                                      "after hanging out in _Atlantis_."
    end

    describe "when description has first names" do
      let(:description) { "Lunch with Elizabeth and John." }
      it "matches friends" do
        subject
        activity.description.
          must_equal "Lunch with **#{friend1.name}** and **#{friend2.name}**."
      end
    end

    describe "when description has nicknames" do
      let(:description) { "Lunch with Lizzy and Johnny." }
      it "matches friends" do
        friend1.add_nickname("Lizzy")
        friend2.add_nickname("Johnny")
        subject
        activity.description.
          must_equal "Lunch with **#{friend1.name}** and **#{friend2.name}**."
      end
    end

    describe "when discription has nicknames which contain first names" do
      let(:nickname1) { "Awesome #{friend1.name}" }
      let(:nickname2) { "Long #{friend2.name} Silver" }
      let(:description) { "Lunch with #{nickname1} and #{nickname2}." }
      it "matches friends" do
        friend1.add_nickname(nickname1)
        friend2.add_nickname(nickname2)
        subject
        activity.description.
          must_equal "Lunch with **#{friend1.name}** and **#{friend2.name}**."
      end
    end

    describe 'when description ends with "<first name> <last name initial>"' do
      let(:description) { "Lunch with John C" }
      it "matches the friend" do
        subject
        activity.description.
          must_equal "Lunch with **#{friend2.name}**"
      end
    end

    describe 'when description ends with "<first name> <last name initial>".' do
      let(:description) { "Lunch with John C." }
      it "matches the friend and keeps the period" do
        subject
        activity.description.
          must_equal "Lunch with **#{friend2.name}**."
      end
    end

    describe "when description has \"<first name> <last name initial>\" in "\
             "the middle of a sentence" do
      let(:description) { "Lunch with John C in the park." }
      it "matches the friend" do
        subject
        activity.description.
          must_equal "Lunch with **#{friend2.name}** in the park."
      end
    end

    describe "when description has \"<first name> <last name initial>.\" in "\
             "the middle of a sentence" do
      let(:description) { "Lunch with John C. in the park." }
      it "matches the friend and swallows the period" do
        subject
        activity.description.
          must_equal "Lunch with **#{friend2.name}** in the park."
      end
    end

    describe "when description has \"<first name> <last name initial>\". at "\
             "the end of a sentence" do
      let(:description) { "Lunch with John C. It was great!" }
      it "matches the friend and keeps the period" do
        subject
        activity.description.
          must_equal "Lunch with **#{friend2.name}**. It was great!"
      end
    end

    describe "when names are not entered case-sensitively" do
      let(:description) { "Lunch with elizabeth cady stanton." }
      it "matches friends" do
        subject
        activity.description.must_equal "Lunch with **Elizabeth Cady Stanton**."
      end
    end

    describe "when name is at beginning of word" do
      let(:description) { "Field trip to the Johnson Co." }
      it "does not match a friend" do
        subject
        # No match found.
        activity.description.must_equal "Field trip to the Johnson Co."
      end
    end

    describe "when name is in middle of word" do
      let(:description) { "Field trip to the JimJohnJames Co." }
      it "does not match a friend" do
        subject
        # No match found.
        activity.description.must_equal "Field trip to the JimJohnJames Co."
      end
    end

    describe "when one name ends another after a hyphen" do
      let(:friend1) { Friends::Friend.new(name: "Mary-Kate Olsen") }
      let(:friend2) { Friends::Friend.new(name: "Kate Winslet") }
      let(:description) { "Shopping with Mary-Kate." }

      it "gives precedence to the larger name" do
        # Make sure "Kate" is a closer friend than "Mary-Kate" so we know our
        # test result isn't due to chance.
        friend1.n_activities = 0
        friend2.n_activities = 10

        subject
        activity.description.must_equal "Shopping with **Mary-Kate Olsen**."
      end
    end

    describe "when one name preceeds another before a hyphen" do
      let(:friend1) { Friends::Friend.new(name: "Mary-Kate Olsen") }
      let(:friend2) { Friends::Friend.new(name: "Mary Poppins") }
      let(:description) { "Shopping with Mary-Kate." }

      it "gives precedence to the larger name" do
        # Make sure "Kate" is a closer friend than "Mary-Kate" so we know our
        # test result isn't due to chance.
        friend1.n_activities = 0
        friend2.n_activities = 10

        subject
        activity.description.must_equal "Shopping with **Mary-Kate Olsen**."
      end
    end

    describe "when one name is contained within another via a hyphen" do
      let(:friend1) { Friends::Friend.new(name: "Mary-Jo-Kate Olsen") }
      let(:friend2) { Friends::Friend.new(name: "Jo Stafford") }
      let(:description) { "Shopping with Mary-Jo-Kate." }

      it "gives precedence to the larger name" do
        # Make sure "Kate" is a closer friend than "Mary-Kate" so we know our
        # test result isn't due to chance.
        friend1.n_activities = 0
        friend2.n_activities = 10

        subject
        activity.description.must_equal "Shopping with **Mary-Jo-Kate Olsen**."
      end
    end

    describe "when name is at end of word" do
      let(:description) { "Field trip to the JimJohn Co." }
      it "does not match a friend" do
        subject
        # No match found.
        activity.description.must_equal "Field trip to the JimJohn Co."
      end
    end

    describe "when name is escaped with a backslash" do
      # We have to use two backslashes here because that's how Ruby encodes one.
      let(:description) { "Dinner with \\Elizabeth Cady Stanton." }
      it "does not match a friend and removes the backslash" do
        subject
        # No match found.
        activity.description.must_equal "Dinner with Elizabeth Cady Stanton."
      end
    end

    describe "when name has leading asterisks" do
      let(:description) { "Dinner with **Elizabeth Cady Stanton." }
      it "does not match a friend" do
        subject
        # No match found.
        activity.description.must_equal "Dinner with **Elizabeth Cady Stanton."
      end
    end

    describe "when name has ending asterisks" do
      let(:description) { "Dinner with Elizabeth**." }
      it "does not match a friend" do
        subject

        # Note: for now we can't guarantee that "Elizabeth Cady Stanton**" won't
        # match, because the Elizabeth isn't surrounded by asterisks.
        activity.description.must_equal "Dinner with Elizabeth**."
      end
    end

    describe "when a friend's name is mentioned multiple times" do
      let(:description) { "Dinner with Elizabeth.  Elizabeth made us pasta." }
      it "highlights all occurrences of the friend's name" do
        subject
        activity.description.
          must_equal "Dinner with **Elizabeth Cady Stanton**."\
                     "  **Elizabeth Cady Stanton** made us pasta."
      end
    end

    describe "when there are multiple matches" do
      describe "when there is context from past activities" do
        let(:description) { "Dinner with Elizabeth and John." }
        let(:friends) do
          [
            friend1,
            friend2,
            Friends::Friend.new(name: "Elizabeth II")
          ]
        end

        it "chooses a match based on the context" do
          # Create a past activity in which Elizabeth Cady Stanton did something
          # with John Cage. Then, create past activities to make Elizabeth II a
          # better friend than Elizabeth Cady Stanton.
          old_activities = [
            Friends::Activity.new(
              str: "#{date_s}#{partition}Picnic with "\
                   "**Elizabeth Cady Stanton** and **John Cage**."
            ),
            Friends::Activity.new(
              str: "#{date_s}#{partition}Got lunch with **Elizabeth II**."
            ),
            Friends::Activity.new(
              str: "#{date_s}#{partition}Ice skated with **Elizabeth II**."
            )
          ]

          # Elizabeth II is the better friend, but historical activities have
          # had Elizabeth Cady Stanton and John Cage together. Thus, we should
          # interpret "Elizabeth" as Elizabeth Cady Stanton.
          stub_activities(old_activities) { subject }

          activity.description.
            must_equal "Dinner with **Elizabeth Cady Stanton** and "\
                       "**John Cage**."
        end
      end

      describe "when there is no context from past activities" do
        let(:description) { "Dinner with Elizabeth." }

        it "falls back to choosing the better friend" do
          friend2.name = "Elizabeth II"

          # Give a past activity to Elizabeth II.
          old_activity = Friends::Activity.new(
            str: "#{date_s}#{partition}Do something with **Elizabeth II**."
          )

          stub_activities([old_activity]) { subject }

          # Pick the friend with more activities.
          activity.description.must_equal "Dinner with **Elizabeth II**."
        end
      end
    end
  end

  describe "#includes_location?" do
    subject { activity.includes_location?(location: loc) }
    let(:loc) { Friends::Location.new(name: "Atlantis") }

    describe "when the given location is in the activity" do
      let(:activity) { Friends::Activity.new(str: "Explored _#{loc.name}_") }
      it { subject.must_equal true }
    end

    describe "when the given location is not in the activity" do
      let(:activity) { Friends::Activity.new(str: "Explored _Elsewhere_") }
      it { subject.must_equal false }
    end
  end

  describe "#includes_friend?" do
    subject { activity.includes_friend?(friend: friend) }

    describe "when the given friend is in the activity" do
      let(:friend) { friend1 }
      it { subject.must_equal true }
    end

    describe "when the given friend is not in the activity" do
      let(:friend) { Friends::Friend.new(name: "Claude Debussy") }
      it { subject.must_equal false }
    end
  end

  describe "#hashtags" do
    subject { activity.hashtags }

    describe "when the activity has no hashtags" do
      let(:activity) { Friends::Activity.new(str: "Enormous ball pit!") }
      it { subject.must_be :empty? }
    end

    describe "when the activity has hashtags" do
      let(:activity) { Friends::Activity.new(str: "Party! #fun #crazy #fun") }
      it { subject.must_equal Set.new(["#fun", "#crazy"]) }
    end
  end

  describe "#includes_hashtag?" do
    subject { activity.includes_hashtag?(hashtag: hashtag) }
    let(:activity) { Friends::Activity.new(str: "Enormous ball pit! #fun") }

    describe "when the given hashtag is not in the activity" do
      let(:hashtag) { "#garbage" }
      it { subject.must_equal false }
    end

    describe "when the given word is in the activity but not as a hashtag" do
      let(:hashtag) { "#ball" }
      it { subject.must_equal false }
    end

    describe "when the given hashtag is in the activity" do
      let(:hashtag) { "#fun" }
      it { subject.must_equal true }
    end
  end

  describe "#friend_names" do
    subject { activity.friend_names }

    it "returns a list of friend names" do
      names = subject

      # We don't assert that the output must be in a specific order because we
      # don't care about the order and it is subject to change.
      names.size.must_equal 2
      names.must_include "Elizabeth Cady Stanton"
      names.must_include "John Cage"
    end

    describe "when a friend is mentioned more than once" do
      let(:description) { "Lunch with **John Cage**. **John Cage** can eat!" }

      it "removes duplicate names" do
        subject.must_equal ["John Cage"]
      end
    end
  end

  describe "#<=>" do
    it "sorts by reverse-date" do
      past_act = Friends::Activity.new(str: "Yesterday: Dummy")
      future_act = Friends::Activity.new(str: "Tomorrow: Dummy")
      [past_act, future_act].sort.must_equal [future_act, past_act]
    end
  end

  describe "#update_friend_name" do
    let(:description) { "Lunch with **John Candy**." }
    subject do
      activity.update_friend_name(
        old_name: "John Candy",
        new_name: "John Cleese"
      )
    end

    it "renames the given friend in the description" do
      subject.must_equal "Lunch with **John Cleese**."
    end

    describe "when the description contains a fragment of the old name" do
      let(:description) { "Lunch with **John Candy** at Johnny's Diner." }

      it "only replaces the name" do
        subject.must_equal "Lunch with **John Cleese** at Johnny's Diner."
      end
    end

    describe "when the description contains the complete old name" do
      let(:description) { "Coffee with **John** at John's Studio." }
      subject do
        activity.update_friend_name(old_name: "John", new_name: "Joe")
      end

      it "only replaces the actual name" do
        subject.must_equal "Coffee with **Joe** at John's Studio."
      end
    end
  end

  describe "#update_location_name" do
    let(:description) { "Lunch in _Paris_." }
    subject do
      activity.update_location_name(
        old_name: "Paris",
        new_name: "Paris, France"
      )
    end

    it "renames the given friend in the description" do
      subject.must_equal "Lunch in _Paris, France_."
    end

    describe "when the description contains a fragment of the old name" do
      let(:description) { "Lunch in _Paris_ at the Parisian Café." }

      it "only replaces the name" do
        subject.must_equal "Lunch in _Paris, France_ at the Parisian Café."
      end
    end

    describe "when the description contains the complete old name" do
      let(:description) { "Lunch in _Paris_ at The Paris Café." }
      subject do
        activity.update_location_name(
          old_name: "Paris",
          new_name: "Paris, France"
        )
      end

      it "only replaces the actual name" do
        subject.must_equal "Lunch in _Paris, France_ at The Paris Café."
      end
    end
  end
end
