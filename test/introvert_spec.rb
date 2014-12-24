require_relative "helper"

describe Friends::Introvert do
  let(:filename) { "test/tmp/friends.md" }
  let(:introvert) { Friends::Introvert.new(filename: filename) }
  let(:friend_names) { ["George Washington Carver", "Betsy Ross"] }
  let(:friends) { friend_names.map { |name| Friends::Friend.new(name: name) } }

  describe "#clean" do
    subject { introvert.clean }

    it "writes cleaned file" do
      sorted_friends = friends.sort_by(&:name)
      unsorted_friends = sorted_friends.reverse

      sorted_names = sorted_friends.map do |friend|
        "#{Friends::Introvert::FRIEND_PREFIX}#{friend.name}"
      end

      name_output = sorted_names.join("\n")
      expected_output =
        "#{Friends::Introvert::FRIENDS_HEADER}\n#{name_output}\n"

      introvert.stub(:friends, unsorted_friends) do
        subject
        File.read(filename).must_equal expected_output
      end

      File.delete(filename)
    end
  end

  describe "#list" do
    subject { introvert.list }

    it "lists the names of friends" do
      introvert.stub(:friends, friends) do
        subject.must_equal friend_names
      end
    end
  end
end
