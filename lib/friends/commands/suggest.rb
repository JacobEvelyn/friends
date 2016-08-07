# frozen_string_literal: true

desc "Suggest friends to do activities with"
command :suggest do |suggest|
  suggest.flag [:in],
               arg_name: "LOCATION",
               desc: "Suggest only friends in the given location",
               type: Stripped

  suggest.action do |_, options|
    suggestions = @introvert.suggest(location_name: options[:in])

    puts "Distant friend: "\
      "#{Paint[suggestions[:distant].sample || 'None found', :bold, :magenta]}"
    puts "Moderate friend: "\
      "#{Paint[suggestions[:moderate].sample || 'None found', :bold, :magenta]}"
    puts "Close friend: "\
      "#{Paint[suggestions[:close].sample || 'None found', :bold, :magenta]}"
  end
end
