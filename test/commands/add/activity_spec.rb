# frozen_string_literal: true

require "date"

require "./test/helper"
require "./test/add_event_helper"

clean_describe "add activity" do
  let(:content) { CONTENT }

  describe "date ordering" do
    let(:content) do
      <<-FILE
### Activities:
- 2018-01-01: Activity one year later.
- 2017-01-01: Activity 1.
- 2016-01-01: Activity one year earlier.

### Notes:

### Friends:

### Locations:
FILE
    end

    subject do
      4.times do |i|
        run_cmd("add activity 2017-01-01: Activity #{i + 2}.")
      end
    end

    it "orders dates by insertion time" do
      subject
      value(File.read(filename)).must_equal <<-FILE
### Activities:
- 2018-01-01: Activity one year later.
- 2017-01-01: Activity 5.
- 2017-01-01: Activity 4.
- 2017-01-01: Activity 3.
- 2017-01-01: Activity 2.
- 2017-01-01: Activity 1.
- 2016-01-01: Activity one year earlier.

### Notes:

### Friends:

### Locations:
FILE
    end
  end

  describe "adding default location" do
    describe "when it is the lastest activity" do
      subject { run_cmd("add activity Moved to _Paris_") }

      describe "when a default location has never been set before" do
      let(:content) do
      <<-FILE
### Activities:
- 2016-01-01: Had dinner in _Berlin_.

### Notes:

### Friends:

### Locations:
- Berlin
FILE
      end

        focus; it 'prints "Default location set to" output message' do
          stdout_for_testing = strip_out_activity(subject[:stdout])
          
          stdout_for_testing.size.must_equal 1
          value(stdout_for_testing.must_include('Default location set to: "Paris"'))
        end
      end

      describe "when current default location is different to the last default location" do
      let(:content) do
      <<-FILE
### Activities:
- 2016-01-01: Moved to _Berlin_.

### Notes:

### Friends:

### Locations:
- Berlin
FILE
      end

        focus; it 'prints "Default location set to" output message' do
          stdout_for_testing = strip_out_activity(subject[:stdout])
          
          stdout_for_testing.size.must_equal 1
          value(stdout_for_testing.must_include('Default location set to: "Paris"'))
        end
      end

      describe "when current default location is the same as the last default location" do
      let(:content) do
      <<-FILE
### Activities:
- 2016-01-01: Flew to _Paris_.

### Notes:

### Friends:

### Locations:
- Paris
FILE
      end

        focus; it 'prints "Default location already set to" output message' do
          stdout_for_testing = strip_out_activity(subject[:stdout])

          stdout_for_testing.size.must_equal 1
          value(stdout_for_testing.must_include('Default location already set to: "Paris"'))
        end
      end
    end

    describe 'when it is not the latest activity' do
      subject { run_cmd("add activity 1999-01-01: Moved to _Paris_") }

      describe 'when a default location has never been set before' do
      let(:content) do
      <<-FILE
### Activities:
- 2016-01-01: Visited my favourite cafe.

### Notes:

### Friends:

### Locations:
FILE
      end

        focus;it 'prints "Default location from [DATE] to present set to" output message' do
          stdout_for_testing = strip_out_activity(subject[:stdout])

          stdout_for_testing.size.must_equal 1
          value(stdout_for_testing.must_include('Default location from 1999-01-01 to present set to: "Paris"'))
        end

      end

      describe 'when default location is the same as the preceding default location' do
      let(:content) do
      <<-FILE
### Activities:
- 2016-01-01: Visited my favourite cafe.
- 1980-01-01: Flew to _Paris_.

### Notes:

### Friends:

### Locations:
- Paris
FILE
      end

      focus;it 'prints "Default location from [DATE] to present already set to" output message' do
        stdout_for_testing = strip_out_activity(subject[:stdout])

        stdout_for_testing.size.must_equal 1
        value(stdout_for_testing.must_include('Default location from 1980-01-01 to present already set to: "Paris"'))
      end

      end

      describe 'when default location precedes a different default location' do
      let(:content) do
      <<-FILE
### Activities:
- 2016-01-01: Flew to _Berlin_.

### Notes:

### Friends:

### Locations:
- Berlin
FILE
      end

      focus;it 'prints "Default location from [DATE] to [DATE] set to" output message' do
        stdout_for_testing = strip_out_activity(subject[:stdout])

        stdout_for_testing.size.must_equal 1
        value(stdout_for_testing.must_include('Default location from 1999-01-01 to 2016-01-01 set to: "Paris"'))
      end

      end

      describe 'when default location precdes a different default location and proceeds the same default location' do
      let(:content) do
      <<-FILE
### Activities:
- 2016-01-01: Flew to _Berlin_.
- 1980-01-01: Flew to _Paris_.

### Notes:

### Friends:

### Locations:
- Berlin
FILE
      end

      focus;it 'prints "Default location from [DATE] to [DATE] already set to" output message' do
        stdout_for_testing = strip_out_activity(subject[:stdout])

        stdout_for_testing.size.must_equal 1
        value(stdout_for_testing.must_include('Default location from 1980-01-01 to 2016-01-01 already set to: "Paris"'))
      end

      end
    end
  end

  parsing_specs(event: :activity)

private
  def strip_out_activity(output)
    lines = output.split("\n")
    lines.reject {|line| !line.include?("Default")}
  end
end
