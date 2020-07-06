# frozen_string_literal: true

desc "Adds a friend (or nickname), activity, note, or location"
command :add do |add|
  add.desc "Adds a friend"
  add.arg_name "NAME"
  add.command :friend do |add_friend|
    add_friend.action do |_, _, args|
      @introvert.add_friend(name: args.join(" ").strip)
      @dirty = true # Mark the file for cleaning.
    end
  end

  [:activity, :note].each do |event|
    add.desc "Adds #{event == :note ? 'a' : 'an'} #{event}"
    add.arg_name "DESCRIPTION"
    add.command event do |add_event|
      add_event.action do |_, _, args|
        @introvert.send("add_#{event}", serialization: args.join(" ").strip)
        @dirty = true # Mark the file for cleaning.
      end
    end
  end

  add.desc "Adds a location"
  add.arg_name "LOCATION"
  add.command :location do |add_location|
    add_location.action do |_, _, args|
      @introvert.add_location(name: args.join(" ").strip)
      @dirty = true # Mark the file for cleaning.
    end
  end

  add.desc "Adds a nickname to a friend"
  add.arg_name "NAME NICKNAME"
  add.command :nickname do |add_nickname|
    add_nickname.action do |_, _, args|
      @introvert.add_nickname(name: args.first.to_s.strip, nickname: args[1].to_s.strip)
      @dirty = true # Mark the file for cleaning.
    end
  end

  add.desc "Adds a tag to a friend"
  add.arg_name "NAME @TAG"
  add.command :tag do |add_tag|
    add_tag.action do |_, _, args|
      @introvert.add_tag(
        name: args[0..-2].join(" "),
        tag: Tag.convert_to_tag(args.last.to_s.strip)
      )
      @dirty = true # Mark the file for cleaning.
    end
  end
end
