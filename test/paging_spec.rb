# frozen_string_literal: true

require "./test/helper"

clean_describe "paging" do
  subject { run_cmd("stats", env_vars: env_vars) }

  let(:content) { nil }
  let(:expected_output) do
    <<-OUTPUT
Total activities: 0
Total friends: 0
Total locations: 0
Total notes: 0
Total tags: 0
Total time elapsed: 0 days
    OUTPUT
  end

  describe "when using the default pager" do
    let(:env_vars) { "" }
    it { stdout_only expected_output }
  end

  describe "when using a custom pager" do
    let(:env_vars) { "FRIENDS_PAGER='head -n 3 | tail -n 2'" }
    it { stdout_only expected_output.split("\n").take(3).drop(1).join("\n") }
  end

  describe "when using a nonexistent pager" do
    let(:env_vars) { "FRIENDS_PAGER=garbage" }
    it { stdout_only expected_output }
  end
end
