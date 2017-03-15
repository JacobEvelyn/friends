# frozen_string_literal: true

desc "Cleans your friends.md file"
command :clean do |clean|
  clean.action do
    @clean_command = true
    @dirty = true # Mark the file for cleaning.
  end
end
