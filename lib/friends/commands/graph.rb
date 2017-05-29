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
    # This math is taken from Minitest's Pride plugin (the PrideLOL class).
    PI_3 = Math::PI / 3

    colors = (0...(6 * 7)).map do |n|
      n *= 1.0 / 6
      r  = (3 * Math.sin(n) + 3).to_i
      g  = (3 * Math.sin(n + 2 * PI_3) + 3).to_i
      b  = (3 * Math.sin(n + 4 * PI_3) + 3).to_i

      [r, g, b].map { |c| c * 51 }
    end

    data = @introvert.graph(
      with: options[:with],
      location_name: options[:in],
      tagged: options[:tagged],
      since_date: options[:since],
      until_date: options[:until]
    )

    data.each do |month, count|
      print "#{month} |"
      puts colors.take(count).map { |rgb| Paint["█", rgb] }.join
    end
  end
end
