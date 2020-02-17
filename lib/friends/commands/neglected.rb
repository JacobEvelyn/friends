# frozen_string_literal: true

desc "List friends who have been neglected"
  command :neglected do |neglected|
    # neglected.flag [:in],
    #                arg_name: "LOCATION",
    #                desc: "Suggest only friends in the given location",
    #                type: Stripped

    neglected.action do |_, options|
      @introvert.neglected#(location_name: options[:in])
    end
  end
