# frozen_string_literal: true

desc "Graph activities over time"
command :graph do |graph|
  graph.flag [:with],
             arg_name: "NAME",
             desc: "Graph activities with the given friend",
             type: Stripped,
             multiple: true

  graph.flag [:in],
             arg_name: "LOCATION",
             desc: "Graph activities in the given location",
             type: Stripped

  graph.flag [:tagged],
             arg_name: "@TAG",
             desc: "Graph activities with the given tag",
             type: Tag,
             multiple: true

  graph.flag [:since],
             arg_name: "DATE",
             desc: "Graph activities on or after the given date",
             type: InputDate

  graph.flag [:until],
             arg_name: "DATE",
             desc: "Graph activities before or on the given date",
             type: InputDate

  graph.action do |_, options|
    @introvert.graph(
      with: options[:with],
      location_name: options[:in],
      tagged: options[:tagged],
      since_date: options[:since],
      until_date: options[:until]
    )
  end
end
