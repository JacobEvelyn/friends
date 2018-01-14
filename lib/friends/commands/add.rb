# frozen_string_literal: true

desc "Adds a friend (or nickname), activity, note, or location"
command :add do |add|
  add.desc "Adds a friend"
  add.arg_name "NAME"
  add.command :friend do |add_friend|
    add_friend.action do |_, _, args|
      friend = @introvert.add_friend(name: args.join(" "))
      @message = "Friend added: \"#{friend.name}\""
      @dirty = true # Mark the file for cleaning.
    end
  end

  [:activity, :note].each do |event|
    add.desc "Adds #{event == :note ? 'a' : 'an'} #{event}"
    add.arg_name "DESCRIPTION"
    add.command event do |add_event|
      add_event.action do |_, _, args|
        event_obj = @introvert.send("add_#{event}", serialization: args.join(" "))

        # If there's no description, prompt the user for one.
        if event_obj.description.nil? || event_obj.description.empty?
          event_obj.description = Readline.readline(event_obj.to_s)
          event_obj.highlight_description(introvert: @introvert)
        end

        @message = "#{event.to_s.capitalize} added: \"#{event_obj}\""
        @dirty = true # Mark the file for cleaning.
      end
    end
  end

  add.desc "Adds a location"
  add.arg_name "LOCATION"
  add.command :location do |add_location|
    add_location.action do |_, _, args|
      location = @introvert.add_location(name: args.join(" "))
      @message = "Location added: \"#{location.name}\""
      @dirty = true # Mark the file for cleaning.
    end
  end

  add.desc "Adds a nickname to a friend"
  add.arg_name "NAME NICKNAME"
  add.command :nickname do |add_nickname|
    add_nickname.action do |_, _, args|
      friend = @introvert.add_nickname(name: args.first, nickname: args[1])
      @message = "Nickname added: \"#{friend}\""
      @dirty = true # Mark the file for cleaning.
    end
  end

  add.desc "Adds a tag to a friend"
  add.arg_name "NAME @TAG"
  add.command :tag do |add_tag|
    add_tag.action do |_, _, args|
      friend = @introvert.add_tag(
        name: args[0..-2].join(" "),
        tag: Tag.convert_to_tag(args.last)
      )
      @message = "Tag added to friend: \"#{friend}\""
      @dirty = true # Mark the file for cleaning.
    end
  end
end
