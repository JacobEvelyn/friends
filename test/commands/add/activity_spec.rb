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
    subject { run_cmd("add activity 2017-01-01: Moved to _Paris_") }

    describe "when default location has not been set before" do
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

      it 'prints "Default location set to" output message' do
        value(subject[:stdout].must_include('Default location set to: "Paris"'))
      end
    end

    describe "when default location has been set two default locations ago" do
    let(:content) do
      <<-FILE
### Activities:
- 2016-01-01: Moved to _Berlin_.
- 2015-01-01: Flew to _Paris_.

### Notes:

### Friends:

### Locations:
- Berlin
- Paris
FILE
    end

      it 'prints "Default location set to" output message' do
        value(subject[:stdout].must_include('Default location set to: "Paris"'))
      end
    end

    describe "when default location has already been set immediately before" do
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

      it 'prints "Default location already set to" output message' do
        value(subject[:stdout].must_include('Default location already set to: "Paris"'))
      end
    end
  end

  parsing_specs(event: :activity)
end
