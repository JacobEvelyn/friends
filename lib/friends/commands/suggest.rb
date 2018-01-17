# frozen_string_literal: true

desc "Suggest friends to do activities with"
command :suggest do |suggest|
  suggest.flag [:in],
               arg_name: "LOCATION",
               desc: "Suggest only friends in the given location",
               type: Stripped

  suggest.action do |_, options|
    @introvert.suggest(location_name: options[:in])
  end
end
