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

      describe "when there is no preceding default location" do
        let(:preceding_activity) { "2016-01-01: Went to the library." }

        it "prints 'Default location set to [LOCATION]'" do
          output = 'Default location set to: "Paris"'
          assert_default_location_output(output)
        end
      end

      describe "when preceding default location is different" do
        let(:preceding_activity) { "2016-01-01: Moved to _Berlin_." }

        it "prints 'Default location set to [LOCATION]'" do
          output = 'Default location set to: "Paris"'
          assert_default_location_output(output)
        end
      end

      describe "when preceding default location is the same" do
        let(:preceding_activity) { "2016-01-01: Flew to _Paris_." }

        it "prints 'Default location already set to [LOCATION]'" do
          output = 'Default location already set to: "Paris"'
          assert_default_location_output(output)
        end
      end
    end

    describe "when it is not the latest activity" do
      subject { run_cmd("add activity 2009-01-01: Moved to _Paris_") }
      let(:content) do
        <<-FILE
### Activities:
- #{following_activity}
- #{preceding_activity}

### Notes:

### Friends:

### Locations:
FILE
      end

      describe "when there is no following default location" do
        let(:following_activity) { "2019-01-01: Visited a cafe" }

        describe "when there is no preceding default location" do
          let(:preceding_activity) { "1999-01-01: Visited a library" }

          it "prints 'Default location from [ADDED ACTIVITY DATE] to present set to [LOCATION]'" do
            message = 'Default location from 2009-01-01 to present set to: "Paris"'
            assert_default_location_output(message)
          end
        end

        describe "when preceding default location is different" do
          let(:preceding_activity) { "1999-01-01: Went to _Berlin_" }

          it "prints 'Default location from [ADDED ACTIVITY DATE] to present set to [LOCATION]'" do
            output = 'Default location from 2009-01-01 to present set to: "Paris"'
            assert_default_location_output(output)
          end
        end

        describe "when preceding default location is same" do
          let(:preceding_activity) { "1999-01-01: Went to _Paris_" }

          it "prints 'Default location from [PRECEDING DEFAULT LOCATION ACTIVITY DATE] to " \
             "present already set to [LOCATION]'" do
            output = 'Default location from 1999-01-01 to present already set to: "Paris"'
            assert_default_location_output(output)
          end
        end

        describe "when multiple preceding default locations are same and consecutive" do
          let(:content) do
            <<-FILE
### Activities:
- 2019-01-01: Visited a cafe
- 1999-01-01: Went to _Paris_
- 1989-01-01: Relocated to _Paris_

### Notes:

### Friends:

### Locations:
FILE
          end

          it "prints 'Default location from " \
             "[EARLIEST CONSECUTIVE DEFAULT LOCATION ACTIVITY DATE] to " \
             "present already set to [LOCATION]'" do
            output = 'Default location from 1989-01-01 to present already set to: "Paris"'
            assert_default_location_output(output)
          end
        end

        describe "when multiple preceding default locations are the same but not consecutive" do
          let(:content) do
            <<-FILE
### Activities:
- 2019-01-01: Visited a cafe
- 1999-01-01: Went to _Paris_
- 1989-01-01: Went to _Berlin_
- 1979-01-01: Relocated to _Paris_

### Notes:

### Friends:

### Locations:
FILE
          end

          it "prints 'Default location from " \
             "[EARLIEST CONSECUTIVE DEFAULT LOCATION ACTIVITY DATE] to " \
             "present already set to [LOCATION]'" do
            output = 'Default location from 1999-01-01 to present already set to: "Paris"'
            assert_default_location_output(output)
          end
        end
      end

      describe "when there are no preceding default locations" do
        let(:preceding_activity) { "1999-01-01: Visited a cafe" }

        describe "when following default location is the same" do
          let(:following_activity) { "2019-01-01: Went to _Paris_" }

          it "prints 'Default location from [ADDED ACTIVITY DATE] to present set to [LOCATION]'" do
            output = 'Default location from 2009-01-01 to present set to: "Paris"'
            assert_default_location_output(output)
          end
        end

        describe "when following default location is different" do
          let(:following_activity) { "2019-01-01: Went to _Berlin_" }

          it "prints 'Default location from [ADDED ACTIVITY DATE] to " \
             "[NEXT DIFFERENT DEFAULT LOCATION ACIVITY DATE] set to [LOCATION]'" do
            output = 'Default location from 2009-01-01 to 2019-01-01 set to: "Paris"'
            assert_default_location_output(output)
          end
        end

        describe "when multiple following default locations are the same and consecutive" do
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

          it "prints 'Default location from [ADDED ACTIVITY DATE] to present set to [LOCATION]'" do
            output = 'Default location from 2009-01-01 to present set to: "Paris"'
            assert_default_location_output(output)
          end
        end

        describe "when multiple following default locations are the same but not consecutive" do
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

          it "prints 'Default location from [ADDED ACTIVITY DATE] to " \
             "[NEXT DIFFERENT DEFAULT LOCATION ACIVITY DATE] set to [LOCATION]'" do
            output = 'Default location from 2009-01-01 to 2018-01-01 set to: "Paris"'
            assert_default_location_output(output)
          end
        end
      end

      describe "when preceding default location is the same" do
        let(:preceding_activity) { "1999-01-01: Went to _Paris_" }

        describe "when following default location is the same" do
          let(:following_activity) { "2019-01-01: Relocated to _Paris_" }

          it "prints 'Default location from " \
             "[PRECEDING ACTIVITY DATE] to present already set to [LOCATION]'" do
            output = 'Default location from 1999-01-01 to present already set to: "Paris"'
            assert_default_location_output(output)
          end
        end

        describe "when following default location is different" do
          let(:following_activity) { "2019-01-01: Relocated to _Berlin_" }

          it "prints 'Default location from " \
             "[PRECEDING ACTIVITY DATE] to " \
             "[FOLLOWING ACTIVITY DATE] set to [LOCATION]'" do
            output = 'Default location from 1999-01-01 to 2019-01-01 already set to: "Paris"'
            assert_default_location_output(output)
          end
        end
      end

      describe "when preceding default location is different" do
        let(:preceding_activity) { "1999-01-01: Went to _Berlin_" }

        describe "when following default location is the same" do
          let(:following_activity) { "2019-01-01: Relocated to _Paris_" }

          it "prints 'Default location from [ADDED ACTIVITY DATE] to present set to [LOCATION]'" do
            output = 'Default location from 2009-01-01 to present set to: "Paris"'
            assert_default_location_output(output)
          end
        end

        describe "when following default location is different" do
          let(:following_activity) { "2019-01-01: Relocated to _Berlin_" }

          it "prints 'Default location from " \
             "[ADDED ACTIVITY DATE] to " \
             "[FOLLOWING ACTIVITY DATE] set to [LOCATION]'" do
            output = 'Default location from 2009-01-01 to 2019-01-01 set to: "Paris"'
            assert_default_location_output(output)
          end
        end
      end

      describe "when activities are out of order" do
        let(:content) do
          <<-FILE
### Activities:
- 2018-01-01: Went to _Berlin_
- 2019-01-01: Went to _Paris_

### Notes:

### Friends:

### Locations:
FILE
        end

        it "uses the sorted order for determining output" do
          output = 'Default location from 2009-01-01 to 2018-01-01 set to: "Paris"'
          assert_default_location_output(output)
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
