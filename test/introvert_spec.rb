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
        date_s: (Date.today - 1).to_s,
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
    after { File.delete(filename) if File.exists?(filename) }

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

    # Delete the file that is created each time.
    after { File.delete(filename) if File.exists?(filename) }

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
    subject { introvert.list_activities(limit: limit, with: with) }
    let(:limit) { nil }
    let(:with) { nil }

    describe "when the limit is lower than the number of activities" do
      let(:limit) { 1 }

      it "lists that number of activities" do
        introvert.stub(:activities, activities) do
          subject.size.must_equal limit
        end
      end
    end

    describe "when the limit is equal to the number of activities" do
      let(:limit) { activities.size }

      it "lists all activities" do
        introvert.stub(:activities, activities) do
          subject.size.must_equal activities.size
        end
      end
    end

    describe "when the limit is greater than the number of activities" do
      let(:limit) { activities.size + 5 }

      it "lists all activities" do
        introvert.stub(:activities, activities) do
          subject.size.must_equal activities.size
        end
      end
    end

    describe "when the limit is nil" do
      let(:limit) { nil }

      it "lists all activities" do
        introvert.stub(:activities, activities) do
          subject.size.must_equal activities.size
        end
      end
    end

    describe "when not filtering by a friend" do
      let(:with) { nil }

      it "lists the activities" do
        introvert.stub(:activities, activities) do
          subject.must_equal activities.map(&:display_text)
        end
      end
    end

    describe "when filtering by part of a friend's name" do
      let(:with) { "george" }

      describe "when there is more than one friend match" do
        let(:friend_names) { ["George Washington Carver", "Boy George"] }

        it "raises an error" do
          introvert.stub(:friends, friends) do
            introvert.stub(:activities, activities) do
              proc { subject }.must_raise Friends::FriendsError
            end
          end
        end
      end

      describe "when there are no friend matches" do
        let(:friend_names) { ["Joe"] }

        it "raises an error" do
          introvert.stub(:friends, friends) do
            introvert.stub(:activities, activities) do
              proc { subject }.must_raise Friends::FriendsError
            end
          end
        end
      end

      describe "when there is exactly one friend match" do
        it "filters the activities by that friend" do
          introvert.stub(:friends, friends) do
            introvert.stub(:activities, activities) do
              # Only one activity has that friend.
              subject.must_equal activities[0..0].map(&:display_text)
            end
          end
        end
      end
    end
  end

  describe "#add_activity" do
    let(:activity_serialization) { "2014-01-01: Snorkeling with Betsy." }
    let(:activity_description) { "Snorkeling with **Betsy Ross**." }
    subject { introvert.add_activity(serialization: activity_serialization) }

    # Delete the file that is created each time.
    after { File.delete(filename) if File.exists?(filename) }

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
    subject { introvert.list_favorites(limit: limit) }

    describe "when limit is nil" do
      let(:limit) { nil }

      it "returns all friends in order of favoritism with activity counts" do
        introvert.stub(:friends, friends) do
          introvert.stub(:activities, activities) do
            subject.must_equal [
              "Betsy Ross               (2 activities)",
              "George Washington Carver (1)"
            ]
          end
        end
      end
    end

    describe "when there are more friends than favorites requested" do
      let(:limit) { 1 }

      it "returns the number of favorites requested" do
        introvert.stub(:friends, friends) do
          introvert.stub(:activities, activities) do
            subject.must_equal ["Betsy Ross (2 activities)"]
          end
        end
      end
    end
  end

  describe "#graph" do
    subject { introvert.graph(name: friend_name) }

    describe "when friend name is invalid" do
      let(:friend_name) { "Oscar the Grouch" }

      it "raises an error" do
        proc { subject }.must_raise Friends::FriendsError
      end
    end

    describe "when friend name has more than one match" do
      let(:friend_name) { "e" }

      it "raises an error" do
        introvert.stub(:friends, friends) do
          proc { subject }.must_raise Friends::FriendsError
        end
      end
    end

    describe "when friend name is valid" do
      let(:friend_name) { "George" }
      let(:activities) do
        [
          Friends::Activity.new(
            date_s: Date.today.to_s,
            description: "Lunch with **George Washington Carver**."
          ),

          # Create another activity with a gap of over a month between it and
          # the next activity, so we can test that we correctly return data for
          # months in the range with no activities.
          Friends::Activity.new(
            date_s: (Date.today - 70).to_s,
            description: "Called **George Washington Carver**."
          ),

          # Create an activity that doesn't involve our friend name.
          Friends::Activity.new(
            date_s: (Date.today - 150).to_s,
            description: "Called **Betsy Ross** on the phone."
          )
        ]
      end

      it "returns a hash of months and frequencies" do
        introvert.stub(:friends, friends) do
          introvert.stub(:activities, activities) do
            strftime_format = Friends::Introvert::GRAPH_DATE_FORMAT

            first = activities[0]
            second = activities[1]
            months = (second.date..first.date).map do |date|
              date.strftime(strftime_format)
            end.uniq

            # Make sure all of the months are in our output data set (even the
            # months with no relevant activity). This also checks that the
            # irrelevant activity is not in our data set.
            subject.keys.must_equal(months)

            # Check that the activities for George are recorded, and that all
            # other months have no activities recorded.
            subject[first.date.strftime(strftime_format)].must_equal 1
            subject[second.date.strftime(strftime_format)].must_equal 1
            subject.values.inject(:+).must_equal 2
          end
        end
      end
    end
  end
end
