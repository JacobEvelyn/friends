require "./test/helper"

describe Friends::Location do
  let(:location_name) { "Jacob Evelyn" }
  let(:loc) { Friends::Location.new(name: location_name) }

  describe ".deserialize" do
    subject { Friends::Location.deserialize(serialized_str) }

    describe "when string is well-formed" do
      let(:serialized_str) do
        "#{Friends::Location::SERIALIZATION_PREFIX}#{location_name}"
      end

      it "creates a location with the correct name" do
        subject.name.must_equal location_name
      end
    end

    describe "when string is malformed" do
      let(:serialized_str) { "" }

      it { proc { subject }.must_raise Serializable::SerializationError }
    end
  end

  describe "#new" do
    subject { loc }

    it { subject.name.must_equal location_name }
  end

  describe "#serialize" do
    subject { loc.serialize }

    it do
      subject.must_equal(
        "#{Friends::Location::SERIALIZATION_PREFIX}#{location_name}"
      )
    end
  end

  describe "#<=>" do
    it "sorts alphabetically" do
      algeria = Friends::Location.new(name: "Algeria")
      zimbabwe = Friends::Location.new(name: "Zimbabwe")
      [zimbabwe, algeria].sort.must_equal [algeria, zimbabwe]
    end
  end
end
