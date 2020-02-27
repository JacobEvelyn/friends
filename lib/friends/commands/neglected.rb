# frozen_string_literal: true

desc "List friends who have been neglected"
  command :neglected do |neglected|
    neglected.flag [:in],
                   arg_name: "LOCATION",
                   desc: "List only friends in the given location",
                   type: Stripped

    neglected.flag [:tagged],
                   arg_name: "@TAG",
                   desc: "List only friends with the given tag",
                   type: Tag,
                   multiple: true

    neglected.action do |_, options|
      @introvert.neglected(location_name: options[:in], tagged: options[:tagged])
    end
  end
