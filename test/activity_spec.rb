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

    describe "when string is malformed" do
      let(:serialized_str) { "" }

      it { proc { subject }.must_raise Serializable::SerializationError }
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
        must_equal "\e[1m#{date_s}\e[0m: "\
          "Lunch with \e[1m#{friend1.name}\e[0m and \e[1m#{friend2.name}\e[0m"
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
    let(:friend1) { Friends::Friend.new(name: "Elizabeth Cady Stanton") }
    let(:friend2) { Friends::Friend.new(name: "John Cage") }
    let(:friends) { [friend1, friend2] }
    let(:description) { "Lunch with #{friend1.name} and #{friend2.name}." }
    subject { activity.highlight_friends(friends: friends) }

    it "finds all friends" do
      subject
      activity.description.
        must_equal "Lunch with **#{friend1.name}** and **#{friend2.name}**."
    end

    it "matches friends' first names" do
      activity = Friends::Activity.new(
        date_s: Date.today.to_s,
        description: "Lunch with Elizabeth and John."
      )
      activity.highlight_friends(friends: friends)
      activity.description.
        must_equal "Lunch with **#{friend1.name}** and **#{friend2.name}**."
    end

    it "matches without case sensitivity" do
      activity = Friends::Activity.new(
        date_s: Date.today.to_s,
        description: "Lunch with elizabeth cady stanton."
      )
      activity.highlight_friends(friends: friends)
      activity.description.
        must_equal "Lunch with **Elizabeth Cady Stanton**."
    end

    it "ignores when there are multiple matches" do
      friend2.name = "Elizabeth II"
      activity = Friends::Activity.new(
        date_s: Date.today.to_s,
        description: "Dinner with Elizabeth."
      )
      activity.highlight_friends(friends: friends)
      activity.description.must_equal "Dinner with Elizabeth." # No match found.
    end

    it "does not match with leading asterisks" do
      activity = Friends::Activity.new(
        date_s: Date.today.to_s,
        description: "Dinner with **Elizabeth Cady Stanton."
      )
      activity.highlight_friends(friends: friends)

      # No match found.
      activity.description.must_equal "Dinner with **Elizabeth Cady Stanton."
    end

    it "does not match with ending asterisks" do
      activity = Friends::Activity.new(
        date_s: Date.today.to_s,

        # Note: for now we can't guarantee that "Elizabeth Cady Stanton**" won't
        # match, because the Elizabeth isn't surrounded by asterisks.
        description: "Dinner with Elizabeth**."
      )
      activity.highlight_friends(friends: friends)

      # No match found.
      activity.description.must_equal "Dinner with Elizabeth**."
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
