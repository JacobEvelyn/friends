require_relative "helper"

describe Friends::Friend do
  let(:friend_name) { "Jacob Evelyn" }
  let(:friend) { Friends::Friend.new(name: friend_name) }

  describe ".deserialize" do
    subject { Friends::Friend.deserialize(serialized_str) }

    describe "when string is well-formed" do
      let(:serialized_str) do
        "#{Friends::Friend::SERIALIZATION_PREFIX}#{friend_name}"
      end

      it "creates a friend with the correct name" do
        subject.name.must_equal friend_name
      end
    end

    describe "when string is malformed" do
      let(:serialized_str) { "" }

      it { proc { subject }.must_raise Serializable::SerializationError }
    end
  end

  describe "#new" do
    subject { friend }

    it { subject.name.must_equal friend_name }
  end

  describe "#serialize" do
    subject { friend.serialize }

    it do
      subject.must_equal(
        "#{Friends::Friend::SERIALIZATION_PREFIX}#{friend_name}"
      )
    end
  end

  describe "#add_nickname" do
    subject { friend.add_nickname("The Dude") }

    it "adds the nickname" do
      subject
      friend.instance_variable_get(:@nicknames).must_include("The Dude")
    end

    it "does not keep duplicates" do
      subject
      subject
      friend.instance_variable_get(:@nicknames).must_equal ["The Dude"]
    end
  end

  describe "#remove_nickname" do
    subject { friend.remove_nickname("Jake") }

    describe "when the nickname is present" do
      let(:friend) do
        Friends::Friend.new(name: friend_name, nickname_str: "a.k.a. Jake")
      end

      it "removes the nickname" do
        friend.instance_variable_get(:@nicknames).must_equal ["Jake"]
        subject
        friend.instance_variable_get(:@nicknames).must_equal []
      end
    end

    describe "when the nickname is not present" do
      it "raises an error if the nickname is not found" do
        proc { subject }.must_raise Friends::FriendsError
      end
    end
  end

  describe "#n_activities" do
    subject { friend.n_activities }

    it "defaults to zero" do
      subject.must_equal 0
    end

    it "is writable" do
      friend.n_activities += 1
      subject.must_equal 1
    end
  end

  describe "#likelihood_score" do
    subject { friend.likelihood_score }

    it "defaults to zero" do
      subject.must_equal 0
    end

    it "is writable" do
      friend.likelihood_score += 1
      subject.must_equal 1
    end
  end

  describe "#regexes_for_name" do
    subject { friend.regexes_for_name }

    it "generates appropriate regexes" do
      subject.must_equal [
        /(?<!\\)(?<!\*\*)(?<![A-z])Jacob\s+Evelyn(?![A-z])(?!\*\*)/i,
        /(?<!\\)(?<!\*\*)(?<![A-z])Jacob(?![A-z])(?!\*\*)/i
      ]
    end
  end

  describe "#<=>" do
    it "sorts alphabetically" do
      aaron = Friends::Friend.new(name: "Aaron")
      zeke = Friends::Friend.new(name: "Zeke")
      [zeke, aaron].sort.must_equal [aaron, zeke]
    end
  end
end
