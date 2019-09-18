# frozen_string_literal: true

require "./lib/friends/post_install_message"
require "./test/helper"

clean_describe "update" do
  subject { run_cmd("update") }
  let(:content) { nil }

  it "prints a status message" do
    subject[:stderr].must_equal ""
    subject[:status].must_equal 0
    [/Updated to friends/, /Already up-to-date/].one? { |m| subject[:stdout] =~ m }.must_equal true
  end

  it "prints the post-install message" do
    subject[:stderr].must_equal ""
    subject[:status].must_equal 0
    subject[:stdout].must_include Friends::POST_INSTALL_MESSAGE
  end
end
