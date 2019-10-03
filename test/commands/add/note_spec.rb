# frozen_string_literal: true

require "date"

require "./test/helper"
require "./test/add_event_helper"

clean_describe "add note" do
  let(:content) { CONTENT }

  describe "date ordering" do
    let(:content) do
      <<-FILE
### Activities:

### Notes:
- 2018-01-01: Note one year later.
- 2017-01-01: Note 1.
- 2016-01-01: Note one year earlier.

### Friends:

### Locations:
FILE
    end

    subject do
      4.times do |i|
        run_cmd("add note 2017-01-01: Note #{i + 2}.")
      end
    end

    it "orders dates by insertion time" do
      subject
      value(File.read(filename)).must_equal <<-FILE
### Activities:

### Notes:
- 2018-01-01: Note one year later.
- 2017-01-01: Note 5.
- 2017-01-01: Note 4.
- 2017-01-01: Note 3.
- 2017-01-01: Note 2.
- 2017-01-01: Note 1.
- 2016-01-01: Note one year earlier.

### Friends:

### Locations:
FILE
    end
  end

  parsing_specs(event: :note)
end
