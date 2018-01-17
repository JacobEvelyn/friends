# frozen_string_literal: true

desc "Opens the `friends.md` file in $EDITOR for manual editing"
command :edit do |edit|
  edit.action do |global_options|
    editor = ENV["EDITOR"] || "vim"
    filename = global_options[:filename]

    puts "Opening \"#{filename}\" with \"#{editor}\"" unless global_options[:quiet]

    # Mark the file for cleaning once the editor was closed correctly.
    if Kernel.system("#{editor} #{filename}")
      @introvert = Friends::Introvert.new(
        filename: global_options[:filename],
        quiet: global_options[:quiet]
      )
      @clean_command = true
      @dirty = true
    elsif !global_options[:quiet]
      puts "Not cleaning file: \"#{filename}\" (\"#{editor}\" did not exit successfully)"
    end
  end
end
