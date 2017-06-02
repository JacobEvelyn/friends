# frozen_string_literal: true

require "./test/helper"

clean_describe "edit" do
  subject do
    stdout, stderr, status = Open3.capture3(
      "EDITOR=cat bundle exec bin/friends --colorless --filename #{filename} edit"
    )
    {
      stdout: stdout,
      stderr: stderr,
      status: status.exitstatus
    }
  end

  let(:content) { CONTENT }

  it 'opens the file in the "editor"' do
    # Because of the way that the edit command uses `Kernel.exec` to replace itself,
    # our `Open3.capture3` call doesn't return STDOUT from before the `Kernel.exec`
    # call, meaning we can't test output of the status message we print out, and
    # our test here can check that STDOUT is equivalent to the `Kernel.exec` command's
    # output, even though visually that's not what happens.
    stdout_only content
  end
end
