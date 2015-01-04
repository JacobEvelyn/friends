require_relative "helper"

describe Friends::Introvert do
  let(:filename) { "test/tmp/friends.md" }
  let(:args) { { filename: filename } }
  let(:introvert) { Friends::Introvert.new(args) }
  let(:friend_names) { ["George Washington Carver", "Betsy Ross"] }
  let(:friends) { friend_names.map { |name| Friends::Friend.new(name: name) } }
  let(:activities) do
    [
      Friends::Activity.new(
        date_s: Date.today.to_s,
        description: "Lunch with **#{friend_names.first}** and "\
          "**#{friend_names.last}**."
      ),
      Friends::Activity.new(
        date_s: (Date.today + 1).to_s,
        description: "Called **#{friend_names.last}**."
      )
    ]
  end

  describe "#new" do
    it "accepts all arguments" do
      introvert # Build a new introvert.

      # Check passed values.
      introvert.filename.must_equal filename
    end

    it "has sane defaults" do
      args.clear # Pass no arguments to the initializer.
      introvert # Build a new introvert.

      # Check default values.
      introvert.filename.must_equal Friends::Introvert::DEFAULT_FILENAME
    end
  end

  describe "#clean" do
    subject { introvert.clean }

    # Delete the file that is created each time.
    after { File.delete(filename) }

    it "writes cleaned file" do
      sorted_friends = friends.sort
      unsorted_friends = sorted_friends.reverse
      sorted_activities = activities.sort
      unsorted_activities = sorted_activities.reverse

      serialized_names = sorted_friends.map(&:serialize)
      name_output = serialized_names.join("\n")

      serialized_descriptions = sorted_activities.map(&:serialize)
      descriptions_output = serialized_descriptions.join("\n")

      expected_output =
        "#{Friends::Introvert::ACTIVITIES_HEADER}\n#{descriptions_output}\n\n"\
        "#{Friends::Introvert::FRIENDS_HEADER}\n#{name_output}\n"

      # Read the input as unsorted, and make sure we get sorted output.
      introvert.stub(:friends, unsorted_friends) do
        introvert.stub(:activities, unsorted_activities) do
          subject
          File.read(filename).must_equal expected_output
        end
      end
    end

    it { subject.must_equal filename }
  end

  describe "#list_friends" do
    subject { introvert.list_friends }

    it "lists the names of friends" do
      introvert.stub(:friends, friends) do
        subject.must_equal friend_names
      end
    end
  end

  describe "#add_friend" do
    let(:new_friend_name) { "Jacob Evelyn" }
    subject { introvert.add_friend(name: new_friend_name) }

    describe "when there is no existing friend with that name" do
      it "adds the given friend" do
        introvert.stub(:friends, friends) do
          subject
          introvert.list_friends.must_include new_friend_name
        end
      end

      it "returns the friend added" do
        introvert.stub(:friends, friends) do
          subject.name.must_equal new_friend_name
        end
      end
    end

    describe "when there is an existing friend with that name" do
      let(:new_friend_name) { friend_names.first }

      it "raises an error" do
        introvert.stub(:friends, friends) do
          proc { subject }.must_raise Friends::FriendsError
        end
      end
    end
  end

  describe "#list_activities" do
    subject { introvert.list_activities(with: with) }

    describe "when not filtering by a friend" do
      let(:with) { nil }

      it "lists the activities" do
        introvert.stub(:activities, activities) do
          subject.must_equal activities.map(&:display_text)
        end
      end
    end

    describe "when filtering by a friend" do
      let(:with) { friend_names.first }

      it "filters the activities by that friend" do
        introvert.stub(:activities, activities) do
          # Only one activity has that friend.
          subject.must_equal activities[0..0].map(&:display_text)
        end
      end
    end
  end

  describe "#add_activity" do
    let(:activity_serialization) { "2014-01-01: Snorkeling with Betsy." }
    let(:activity_description) { "Snorkeling with **Betsy Ross**." }
    subject { introvert.add_activity(serialization: activity_serialization) }

    it "adds the given activity" do
      introvert.stub(:friends, friends) do
        subject
        introvert.activities.last.description.must_equal activity_description
      end
    end

    it "returns the activity added" do
      introvert.stub(:friends, friends) do
        subject.description.must_equal activity_description
      end
    end
  end

  describe "#list_favorites" do
    subject { introvert.list_favorites }

    it "returns the friends in order of favoritism" do
      introvert.stub(:friends, friends) do
        introvert.stub(:activities, activities) do
          subject.must_equal ["Betsy Ross", "George Washington Carver"]
        end
      end
    end

    describe "when there are more friends than favorites requested" do
      subject { introvert.list_favorites(num: 1) }

      it "returns the number of favorites requested" do
        introvert.stub(:friends, friends) do
          introvert.stub(:activities, activities) do
            subject.must_equal ["Betsy Ross"]
          end
        end
      end
    end
  end
end
