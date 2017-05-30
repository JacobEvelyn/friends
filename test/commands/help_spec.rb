# frozen_string_literal: true

require "./test/helper"

clean_describe "help" do
  subject { run_cmd("help") }
  let(:content) { nil }

  describe "with no subcommand passed" do
    it "prints overall help message" do
      subject[:stderr].must_equal ""
      subject[:status].must_equal 0
      [
        "NAME",
        "SYNOPSIS",
        "VERSION",
        "GLOBAL OPTIONS",
        "COMMANDS"
      ].all? { |msg| subject[:stdout].include? msg }.must_equal true
    end
  end

  describe "with a subcommand passed" do
    subject { run_cmd("help graph") }

    it "prints subcommand help message" do
      subject[:stderr].must_equal ""
      subject[:status].must_equal 0
      [
        "NAME",
        "SYNOPSIS",
        "COMMAND OPTIONS"
      ].all? { |msg| subject[:stdout].include? msg }.must_equal true
    end
  end

  describe "with an invalid subcommand passed" do
    subject { run_cmd("help garbage") }

    # FIXME uncomment!!!
    # Waiting for: https://github.com/davetron5000/gli/issues/255
    # it "prints an error message" do
    #   stderr_only "error: Unknown command 'garbage'.  Use 'friends help' for a list of commands."
    # end
  end
end
