# frozen_string_literal: true

desc "Opens the `friends.md` file in $EDITOR for manual editing"
command :edit do |edit|
  edit.action do |global_options|
    editor = ENV["EDITOR"] || "vim"
    filename = global_options[:filename]

    puts "Opening \"#{filename}\" in #{editor}" unless global_options[:quiet]
    Kernel.exec "#{editor} #{filename}"
  end
end
