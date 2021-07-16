# frozen_string_literal: true

require "./test/helper"

# Since this touches the ~/friends.md file instead of a temp
# one, we only want to run it on our CI servers.
if ENV["CI"] == "true"
  describe "default filename behavior" do
    let(:filename) { File.expand_path("~/friends.md") }

    after { File.delete(filename) }

    # Since the filename is the system-wide one, we can't have
    # more than one test that touches it, because multiple
    # tests can run in parallel and might stomp on one another.
    # Instead, we just run one test that exercises a lot.
    # This test specifically checks for regressions akin to
    # https://github.com/JacobEvelyn/friends/issues/231
    it "creates a new file and adds to it multiple times" do
      # File does not exist at first.
      value(File.exist?(filename)).must_equal false

      `bundle exec bin/friends add friend Mohandas Karamchand Gandhi`
      `bundle exec bin/friends add friend Sojourner Truth`
      `bundle exec bin/friends add activity 1859-11-30: Lunch with **Harriet Tubman** in _Auburn_.`
      `bundle exec bin/friends add note "1851-05-29: Sojourner Truth's speech"`

      value(File.read(filename)).must_equal <<-FILE
### Activities:
- 1859-11-30: Lunch with **Harriet Tubman** in _Auburn_.

### Notes:
- 1851-05-29: **Sojourner Truth**'s speech

### Friends:
- Harriet Tubman
- Mohandas Karamchand Gandhi
- Sojourner Truth

### Locations:
- Auburn
      FILE
    end
  end
end
