# frozen_string_literal: true

require "./test/helper"

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

    describe "when string has one nickname" do
      let(:serialized_str) { "Guybrush Threepwood (a.k.a. Brush)" }
      it { subject.name.must_equal "Guybrush Threepwood" }
      it { subject.instance_variable_get(:@nicknames).must_equal ["Brush"] }
    end

    describe "when string has multiple nicknames" do
      let(:serialized_str) { "Guybrush Threepwood (a.k.a. Brush a.k.a. Guy)" }
      it { subject.name.must_equal "Guybrush Threepwood" }
      it do
        subject.instance_variable_get(:@nicknames).must_equal ["Brush", "Guy"]
      end
    end

    describe "when string has a location" do
      let(:serialized_str) { "Guybrush Threepwood [Plunder Island]" }
      it { subject.name.must_equal "Guybrush Threepwood" }
      it { subject.location_name.must_equal "Plunder Island" }
    end

    describe "when string has one tag" do
      let(:serialized_str) { "Guybrush Threepwood @pirate" }
      it { subject.name.must_equal "Guybrush Threepwood" }
      it { subject.tags.must_equal ["@pirate"] }
    end

    describe "when string has multiple tags" do
      let(:serialized_str) { "Guybrush Threepwood @pirate @swashbuckler" }
      it { subject.name.must_equal "Guybrush Threepwood" }
      it { subject.tags.must_equal ["@pirate", "@swashbuckler"] }
    end

    describe "when string has nicknames and tags" do
      let(:serialized_str) do
        "Guybrush Threepwood (a.k.a. Brush a.k.a. Guy) @pirate @swashbuckler"
      end
      it { subject.name.must_equal "Guybrush Threepwood" }
      it do
        subject.instance_variable_get(:@nicknames).must_equal ["Brush", "Guy"]
      end
      it { subject.tags.must_equal ["@pirate", "@swashbuckler"] }
    end

    describe "when string has nicknames and a location" do
      let(:serialized_str) do
        "Guybrush Threepwood (a.k.a. Brush a.k.a. Guy) [Plunder Island]"
      end
      it { subject.name.must_equal "Guybrush Threepwood" }
      it do
        subject.instance_variable_get(:@nicknames).must_equal ["Brush", "Guy"]
      end
      it { subject.location_name.must_equal "Plunder Island" }
    end

    describe "when string has a location and tags" do
      let(:serialized_str) do
        "Guybrush Threepwood [Plunder Island] @pirate @swashbuckler"
      end
      it { subject.name.must_equal "Guybrush Threepwood" }
      it { subject.location_name.must_equal "Plunder Island" }
      it { subject.tags.must_equal ["@pirate", "@swashbuckler"] }
    end

    describe "when string has nicknames, a location, and tags" do
      let(:serialized_str) do
        "Guybrush Threepwood (a.k.a. Brush a.k.a. Guy) [Plunder Island] "\
          "@pirate @swashbuckler"
      end
      it { subject.name.must_equal "Guybrush Threepwood" }
      it do
        subject.instance_variable_get(:@nicknames).must_equal ["Brush", "Guy"]
      end
      it { subject.location_name.must_equal "Plunder Island" }
      it { subject.tags.must_equal ["@pirate", "@swashbuckler"] }
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
      # Add the same nickname twice. Do not use `subject` because it's memoized.
      friend.add_nickname("The Dude")
      friend.add_nickname("The Dude")

      friend.instance_variable_get(:@nicknames).must_equal ["The Dude"]
    end
  end

  describe "#remove_nickname" do
    subject { friend.remove_nickname("Jake") }

    describe "when the nickname is present" do
      let(:friend) do
        Friends::Friend.new(name: friend_name, nickname_str: "Jake")
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

  describe "#add_tag" do
    subject { friend.add_tag("@college") }

    it "adds the nickname" do
      subject
      friend.tags.must_include("@college")
    end

    it "does not keep duplicates" do
      # Add the same nickname twice. Do not use `subject` because it's memoized.
      friend.add_tag("@college")
      friend.add_tag("@college")

      friend.tags.must_equal ["@college"]
    end
  end

  describe "@remove_tag" do
    subject { friend.remove_tag("@school") }

    describe "when the tag is present" do
      let(:friend) do
        Friends::Friend.new(name: friend_name, tags_str: "@school @work")
      end

      it "removes the nickname" do
        friend.instance_variable_get(:@tags).must_equal ["@school", "@work"]
        subject
        friend.instance_variable_get(:@tags).must_equal ["@work"]
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
      subject.any? { |r| r =~ friend_name }.must_equal true
      subject.any? { |r| r =~ friend_name.partition(" ").first }.must_equal true
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
