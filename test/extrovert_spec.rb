require_relative "helper"

describe Friends::Extrovert do
  let(:extrovert) { Friends::Extrovert.new }
  let(:introvert_mock) { Minitest::Mock.new }

  describe "#clean" do
    subject { extrovert.clean }

    it "uses the introvert to clean the file" do
      Friends::Introvert.stub(:new, introvert_mock) do
        introvert_mock.expect :clean, nil
        subject
        introvert_mock.verify
      end
    end
  end

  describe "#list" do
    subject { extrovert.list }

    it "lists the names retrieved from the introvert" do
      Friends::Introvert.stub(:new, introvert_mock) do
        introvert_mock.expect :list, []
        subject
        introvert_mock.verify
      end
    end
  end
end
