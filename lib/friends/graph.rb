# frozen_string_literal: true
# Graphs activities by month

module Friends
  class Graph
    DATE_FORMAT = "%b %Y"

    # @param start_date [Date] the first month of the graph
    # @param end_date [Date] the last month of the graph
    # @param activities [Array<Friends::Activity>] a list of activities to graph
    def initialize(start_date:, end_date:, activities:)
      self.start_date = start_date
      self.end_date = end_date
      self.activities = activities
    end

    # Render the graph as a hash in the format:
    #
    #   {
    #     "Jan 2015" => 3, # The number of activities during each month.
    #     "Feb 2015" => 0,
    #     "Mar 2015" => 9
    #   }
    #
    # @return [Hash{String => Integer}]
    def to_h
      empty_graph.tap do |graph|
        activities.each do |activity|
          graph[format_date(activity.date)] += 1
        end
      end
    end

    private

    attr_accessor :start_date, :end_date, :activities

    # Render an empty graph as a hash in the format:
    #
    #   {
    #     "Jan 2015" => 0,
    #     "Feb 2015" => 0,
    #     "Mar 2015" => 0
    #   }
    #
    # @return [Hash{String => Integer}]
    def empty_graph
      Hash[(start_date..end_date).map do |date|
        [format_date(date), 0]
      end]
    end

    # Format a date for use in the graph label
    # @param date [Date] the date to format
    # @return [String]
    def format_date(date)
      date.strftime(DATE_FORMAT)
    end
  end
end
