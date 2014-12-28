require_relative "helper"

describe Friends::Activity do
  let(:date) { Date.today }
  let(:date_s) { date.to_s }
  let(:friend1) { Friends::Friend.new(name: "Thing 1") }
  let(:friend2) { Friends::Friend.new(name: "Thing 2") }
  let(:description) { "Lunch with **#{friend1.name}** and **#{friend2.name}**" }
  let(:activity) do
    Friends::Activity.new(date_s: date_s, description: description)
  end

  describe ".deserialize" do
    subject { Friends::Activity.deserialize(serialized_str) }

    describe "when string is well-formed" do
      let(:serialized_str) do
        "#{Friends::Activity::SERIALIZATION_PREFIX}#{date_s}: #{description}"
      end

      it "creates an activity with the correct date and description" do
        new_activity = subject
        new_activity.date.must_equal date
        new_activity.description.must_equal description
      end
    end

    describe "when string is malformed" do
      # No serialization prefix, so string is malformed.
      let(:serialized_str) { "#{date_s}: #{description}" }

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
