# frozen_string_literal: true

desc "Remove a nickname"
command :remove do |remove|
  remove.desc "Removes a nickname from a friend"
  remove.arg_name "NAME NICKNAME"
  remove.command :nickname do |remove_nickname|
    remove_nickname.action do |_, _, args|
      @introvert.remove_nickname(name: args.first, nickname: args[1])
      @dirty = true # Mark the file for cleaning.
    end
  end

  remove.desc "Removes a tag from a friend"
  remove.arg_name "NAME @TAG"
  remove.command :tag do |remove_tag|
    remove_tag.action do |_, _, args|
      @introvert.remove_tag(
        name: args[0..-2].join(" "),
        tag: Tag.convert_to_tag(args.last)
      )
      @dirty = true # Mark the file for cleaning.
    end
  end
end
