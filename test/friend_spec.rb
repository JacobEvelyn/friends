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

  describe "#<=>" do
    it "sorts alphabetically" do
      aaron = Friends::Friend.new(name: "Aaron")
      zeke = Friends::Friend.new(name: "Zeke")
      [zeke, aaron].sort.must_equal [aaron, zeke]
    end
  end
end
