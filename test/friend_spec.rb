require_relative "helper"

describe Friends::Friend do
  describe "#name" do
    it "returns name" do
      Friends::Friend.new(name: "Jacob").name.must_equal "Jacob"
    end
  end
end
