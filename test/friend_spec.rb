require_relative "helper"

describe Friends::Friend do
  describe "#name" do
    subject { Friends::Friend.new(name: "Jacob") }

    it "returns name" do
      subject.name.must_equal "Jacob"
    end
  end
end
