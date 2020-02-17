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
    describe "when it is the latest activity" do
      subject { run_cmd("add activity Moved to _Paris_") }
      let(:content) do
        <<-FILE
### Activities:
- #{preceding_activity}

### Notes:

### Friends:

### Locations:
FILE
      end

      describe "when a default location has never been set before" do
        let(:preceding_activity) { "2016-01-01: Had dinner in _Berlin_." }


        it 'prints "Default location set to" output message' do
          assert_default_location_output('Default location set to: "Paris"')
        end
      end

      describe "when preceding default location is different" do
        let(:preceding_activity) { "2016-01-01: Moved to _Berlin_." }
        it 'prints "Default location set to" output message' do
          assert_default_location_output('Default location set to: "Paris"')
        end
      end

      describe "when preceding default location is the same" do
        let(:preceding_activity) { "2016-01-01: Flew to _Paris_." }

        it 'prints "Default location already set to" output message' do
          assert_default_location_output('Default location already set to: "Paris"')
        end
      end
    end

    describe "when it is not the latest activity" do
      subject { run_cmd("add activity 2009-01-01: Moved to _Paris_") }
      let(:content) do
  <<-FILE
### Activities:
- #{proceeding_activity}
- #{preceding_activity}

### Notes:

### Friends:

### Locations:
FILE
      end

      describe "when proceeding activities have no default location" do
        let(:proceeding_activity) { "2019-01-01: Visted a cafe"}

        describe "when preceding activities have no default location" do
          let(:preceding_activity) { "1999-01-01: Visted a library"}

          it 'prints "Default location from [ADDED ACTIVITY DATE] to present set to" output message' do
            assert_default_location_output('Default location from 2009-01-01 to present set to: "Paris"')
          end

        end

        describe "when preceding default location is different" do
          let(:preceding_activity) { "1999-01-01: Went to _Berlin_"}

          it 'prints "Default location from [ADDED ACTIVITY DATE] to present set to" output message' do
            assert_default_location_output('Default location from 2009-01-01 to present set to: "Paris"')
          end

        end

        describe "when preceding default location is same" do
          let(:preceding_activity) { "1999-01-01: Went to _Paris_"}

          it 'prints "Default location from [PRECEDING ACTIVITY DATE] to present already set to" output message' do
            assert_default_location_output('Default location from 1999-01-01 to present already set to: "Paris"')
          end

        end

        describe "when multiple preceding default locations are same and consecutive" do
          let(:preceding_activity) { "1999-01-01: Went to _Paris_"}
          let(:content) do
            <<-FILE
### Activities:
- 2019-01-01: Visted a cafe
- 1999-01-01: Went to _Paris_
- 1989-01-01: Relocated to _Paris_

### Notes:

### Friends:

### Locations:
FILE
          end

          it 'prints "Default location from [EARLIEST CONSECUTIVE DEFAULT LOCATION ACTIVITY DATE] to present already set to" output message' do
            assert_default_location_output('Default location from 1989-01-01 to present already set to: "Paris"')
          end

        end

        describe "when multiple preceding default locations are the same but not consecutive" do
          let(:content) do
            <<-FILE
### Activities:
- 2019-01-01: Visted a cafe
- 1999-01-01: Went to _Paris_
- 1989-01-01: Went to _Berlin_
- 1979-01-01: Relocated to _Paris_

### Notes:

### Friends:

### Locations:
FILE
          end

          it 'prints "Default location from [EARLIEST CONSECUTIVE DEFAULT LOCATION ACTIVITY DATE] to present already set to" output message' do
            assert_default_location_output('Default location from 1999-01-01 to present already set to: "Paris"')
          end

        end

      end

      describe 'when preceding activities have no default locations' do
        let(:preceding_activity) { "1999-01-01: Visted a cafe"}

        describe 'when single proceeding default location is the same' do
          let(:proceeding_activity) { "2019-01-01: Went to _Paris_"}

          it 'prints "Default location from [ADDED ACTIVITY DATE] to present set to" output message' do
            assert_default_location_output('Default location from 2009-01-01 to present set to: "Paris"')
          end

        end

        describe 'when proceeding default location is different' do
          let(:proceeding_activity) { "2019-01-01: Went to _Berlin_"}

          it 'prints "Default location from [ADDED ACTIVITY DATE] to [DIFFERENT DEFAULT LOCATION ACTIVITY DATE] set to" output message' do
            assert_default_location_output('Default location from 2009-01-01 to 2019-01-01 set to: "Paris"')
          end

        end

        describe "when multiple proceeding default locations are the same and consecutive" do
          let(:content) do
            <<-FILE
### Activities:
- 2019-01-01: Went to _Paris_
- 2018-01-01: Relocated to _Paris_

### Notes:

### Friends:

### Locations:
FILE
          end

          it 'prints "Default location from [ADDED ACTIVITY DATE] to present set to" output message' do
            assert_default_location_output('Default location from 2009-01-01 to present set to: "Paris"')
          end

        end

        describe "when multiple proceeding default locations are the same but not consecutive" do
          let(:content) do
            <<-FILE
### Activities:
- 2019-01-01: Went to _Paris_
- 2018-01-01: Went to _Berlin_
- 2017-01-01: Relocated to _Paris_

### Notes:

### Friends:

### Locations:
FILE
          end

          it 'prints "Default location from [ADDED ACTIVITY DATE] to [NEXT DIFFERENT DEFAULT LOCATION ACIVITY DATE] set to" output message' do
            assert_default_location_output('Default location from 2009-01-01 to 2018-01-01 set to: "Paris"')
          end

        end

      end

      describe 'when preceding default location is the same' do
        let(:preceding_activity) { "1999-01-01: Went to _Paris_"}
        
        describe 'when proceeding default location is the same' do
          let(:proceeding_activity) { "2019-01-01: Relocated to _Paris_"}

          it 'prints "Default location from [PRECEDING ACTIVITY DATE] to present set to" output message' do
            assert_default_location_output('Default location from 1999-01-01 to present already set to: "Paris"')
          end

        end  

        describe 'when proceeding default location is different' do
          let(:proceeding_activity) { "2019-01-01: Relocated to _Berlin_"}

          it 'prints "Default location from [PRECEDING ACTIVITY DATE] to [PROCEEDING ACTIVITY DATE] set to" output message' do
            assert_default_location_output('Default location from 1999-01-01 to 2019-01-01 already set to: "Paris"')
          end

        end

      end

      describe 'when preceding default location is different' do
        let(:preceding_activity) { "1999-01-01: Went to _Berlin_"}
        
        describe 'when proceeding default location is the same' do
          let(:proceeding_activity) { "2019-01-01: Relocated to _Paris_"}

          it 'prints "Default location from [ADDED ACTIVITY DATE] to present set to" output message' do
            assert_default_location_output('Default location from 2009-01-01 to present set to: "Paris"')
          end

        end  

        describe 'when proceeding default location is different' do
          let(:proceeding_activity) { "2019-01-01: Relocated to _Berlin_"}

          it 'prints "Default location from [ADDED ACTIVITY DATE] to [PROCEEDING ACTIVITY DATE] set to" output message' do
            assert_default_location_output('Default location from 2009-01-01 to 2019-01-01 set to: "Paris"')
          end
        end
      end
    end
  end

  parsing_specs(event: :activity)

  private

  def assert_default_location_output(expected_output)
    output = select_default_activity_output(subject[:stdout])

    output.size.must_equal(1)
    output.must_include(expected_output)
  end

  def select_default_activity_output(output)
    lines = output.split("\n")
    lines.select { |line| line.include?("Default") }
  end

end
