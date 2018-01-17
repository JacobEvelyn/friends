# frozen_string_literal: true

desc "Set data about friends"
command :set do |set|
  set.desc "Set a friend's location"
  set.arg_name "NAME LOCATION"
  set.command :location do |set_location|
    set_location.action do |_, _, args|
      @introvert.set_location(name: args.first, location_name: args[1])
      @dirty = true # Mark the file for cleaning.
    end
  end
end
