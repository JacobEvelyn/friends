# frozen_string_literal: true

desc "Renames a friend or location"
command :rename do |rename|
  rename.desc "Renames a friend"
  rename.arg_name "NAME NEW_NAME"
  rename.command :friend do |rename_friend|
    rename_friend.action do |_, _, args|
      friend = @introvert.rename_friend(
        old_name: args.first,
        new_name: args[1]
      )
      @message = "Name changed: \"#{friend}\""
      @dirty = true # Mark the file for cleaning.
    end
  end

  rename.desc "Renames a location"
  rename.arg_name "NAME NEW_NAME"
  rename.command :location do |rename_location|
    rename_location.action do |_, _, args|
      location = @introvert.rename_location(
        old_name: args.first,
        new_name: args[1]
      )
      @message = "Location renamed: \"#{location.name}\""
      @dirty = true # Mark the file for cleaning.
    end
  end
end
