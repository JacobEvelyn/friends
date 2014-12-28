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
        description: "Lunch with **#{friend_names.first}**."
      ),
      Friends::Activity.new(
        date_s: (Date.today + 1).to_s,
        description: "Called **#{friend_names.last}**."
      )
    ]
  end

  describe "#new" do
    it "accepts all arguments" do
      args.merge!(verbose: true)
      introvert # Build a new introvert.

      # Check passed values.
      introvert.filename.must_equal filename
      introvert.verbose.must_equal true
    end

    it "has sane defaults" do
      args.clear # Pass no arguments to the initializer.
      introvert # Build a new introvert.

      # Check default values.
      introvert.filename.must_equal Friends::Introvert::DEFAULT_FILENAME
      introvert.verbose.must_equal false
    end
  end

  describe "#clean" do
    subject { introvert.clean }

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
        "#{Friends::Introvert::FRIENDS_HEADER}\n#{name_output}\n\n"\
        "#{Friends::Introvert::ACTIVITIES_HEADER}\n#{descriptions_output}\n"

      # Read the input as unsorted, and make sure we get sorted output.
      introvert.stub(:friends, unsorted_friends) do
        introvert.stub(:activities, unsorted_activities) do
          subject
          File.read(filename).must_equal expected_output
        end
      end

      File.delete(filename)
    end
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
end
