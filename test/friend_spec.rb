require_relative "helper"

describe Friends::Friend do
  describe "#new" do
    subject { Friends::Friend.new(name: "Jacob") }

    it { subject.name.must_equal "Jacob" }
  end
end
