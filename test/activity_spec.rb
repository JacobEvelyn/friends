require_relative "helper"

describe Friends::Activity do
  let(:date) { Date.today }
  let(:date_s) { date.to_s }
  let(:friend1) { Friends::Friend.new(name: "Elizabeth Cady Stanton") }
  let(:friend2) { Friends::Friend.new(name: "John Cage") }
  let(:description) { "Lunch with **#{friend1.name}** and **#{friend2.name}**" }
  let(:activity) do
    Friends::Activity.new(date_s: date_s, description: description)
  end

  describe ".deserialize" do
    subject { Friends::Activity.deserialize(serialized_str) }

    describe "when string is well-formed" do
      let(:serialized_str) { "#{date_s}: #{description}" }

      it "creates an activity with the correct date and description" do
        new_activity = subject
        new_activity.date.must_equal date
        new_activity.description.must_equal description
      end
    end

    describe "when no date is present" do
      let(:serialized_str) { description }

      it "defaults to today" do
        today = Date.today

        # We stub out Date.today to guarantee that it is always the same even
        # when the date changes in the middle of the test's execution.
        Date.stub(:today, today) { subject.date.must_equal today }
      end
    end

    describe "when no description is present" do
      let(:serialized_str) { "" }

      it "sets no description in deserialization" do
        subject.description.must_equal nil
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
          "#{Paint[friend2.name, :bold, :magenta]}"
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

  describe "#highlight_friends" do
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

    let(:friends) { [friend1, friend2] }
    let(:introvert) { Friends::Introvert.new }
    subject do
      stub_friends(friends) { activity.highlight_friends(introvert: introvert) }
    end

    it "finds all friends" do
      subject
      activity.description.
        must_equal "Lunch with **#{friend1.name}** and **#{friend2.name}**"
    end

    describe "when description has first names" do
      let(:description) { "Lunch with Elizabeth and John." }
      it "matches friends" do
        subject
        activity.description.
          must_equal "Lunch with **#{friend1.name}** and **#{friend2.name}**."
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
              date_s: date_s,
              description: "Picnic with **Elizabeth Cady Stanton** and "\
                           "**John Cage**."
            ),
            Friends::Activity.new(
              date_s: date_s,
              description: "Got lunch with with **Elizabeth II**."
            ),
            Friends::Activity.new(
              date_s: date_s,
              description: "Ice skated with **Elizabeth II**."
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
            date_s: date_s,
            description: "Do something with **Elizabeth II**."
          )

          stub_activities([old_activity]) { subject }

          # Pick the friend with more activities.
          activity.description.must_equal "Dinner with **Elizabeth II**."
        end
      end
    end
  end

  describe "#includes_friend?" do
    subject { activity.includes_friend?(friend: friend) }

    describe "when the given friend is in the activity" do
      let(:friend) { friend1 }

      it "returns true" do
        subject.must_equal true
      end
    end

    describe "when the given friend is not in the activity" do
      let(:friend) { Friends::Friend.new(name: "Claude Debussy") }

      it "returns false" do
        subject.must_equal false
      end
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
      yesterday = (Date.today - 1).to_s
      tomorrow = (Date.today + 1).to_s
      past_act = Friends::Activity.new(date_s: yesterday, description: "Dummy")
      future_act = Friends::Activity.new(date_s: tomorrow, description: "Dummy")
      [past_act, future_act].sort.must_equal [future_act, past_act]
    end
  end
end
