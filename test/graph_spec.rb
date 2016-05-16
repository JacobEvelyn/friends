# frozen_string_literal: true
require "./test/helper"

describe Friends::Graph do
  subject do
    Friends::Graph.new(
      start_date: start_date,
      end_date: end_date,
      activities: activities
    ).to_h
  end

  let(:start_date) { Date.new(2016, 1, 1) }
  let(:end_date) { Date.new(2016, 2, 1) }
  let(:activities) do
    [
      Friends::Activity.new(
        str: "2016-02-01: Relaxing."
      ),

      Friends::Activity.new(
        str: "2016-01-01: Running."
      )
    ]
  end

  it "graphs activities by month" do
    subject.must_equal(
      "Jan 2016" => 1,
      "Feb 2016" => 1
    )
  end

  describe "there is a gap between activities" do
    let(:end_date) { Date.new(2016, 3, 1) }

    let(:activities) do
      [
        Friends::Activity.new(
          str: "2016-03-01: Relaxing."
        ),

        Friends::Activity.new(
          str: "2016-01-01: Running."
        )
      ]
    end

    it "includes the month with no activities" do
      subject.must_equal(
        "Jan 2016" => 1,
        "Feb 2016" => 0,
        "Mar 2016" => 1
      )
    end
  end

  describe "graph starts before the first activity" do
    let(:start_date) { Date.new(2015, 12, 1) }

    it "graphs activities by month" do
      subject.must_equal(
        "Dec 2015" => 0,
        "Jan 2016" => 1,
        "Feb 2016" => 1
      )
    end
  end

  describe "graph ends after the last activity" do
    let(:end_date) { Date.new(2016, 3, 1) }

    it "graphs activities by month" do
      subject.must_equal(
        "Jan 2016" => 1,
        "Feb 2016" => 1,
        "Mar 2016" => 0
      )
    end
  end

  describe "there are no activities" do
    let(:activities) { [] }

    it "graphs activities by month" do
      subject.must_equal(
        "Jan 2016" => 0,
        "Feb 2016" => 0
      )
    end
  end
end
