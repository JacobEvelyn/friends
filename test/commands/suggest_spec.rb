# frozen_string_literal: true

require "./test/helper"

clean_describe "suggest" do
  subject { run_cmd("suggest") }

  describe "when file does not exist" do
    it "prints a no-data message" do
      stdout_only <<-FILE
Distant friend: None found
Moderate friend: None found
Close friend: None found
      FILE
    end
  end

  describe "when the file is empty" do
    let(:content) { "" }

    it "prints a no-data message" do
      stdout_only <<-FILE
Distant friend: None found
Moderate friend: None found
Close friend: None found
      FILE
    end
  end

  describe "when file has content" do
    let(:content) do
      <<-FILE
### Activities:
- 2017-03-01: Met up with **George Washington Carver**.
- 2017-02-01: Met up with **George Washington Carver**.
- 2017-01-01: Met up with **George Washington Carver**.
- 2016-12-01: Met up with **Grace Hopper**.
- 2016-11-01: Met up with **Grace Hopper**.
- 2016-10-01: Met up with **Grace Hopper**.
- 2016-09-01: Met up with **Grace Hopper**.
- 2016-08-01: Met up with **Grace Hopper**.
- 2016-07-01: Met up with **Grace Hopper**.
- 2016-06-01: Met up with **Grace Hopper**.
- 2016-05-01: Met up with **Grace Hopper**.
- 2016-04-01: Met up with **Grace Hopper**.
- 2016-03-01: Met up with **Grace Hopper**.
- 2016-02-01: Met up with **Grace Hopper**.
- 2016-01-01: Met up with **Grace Hopper**.
- 2015-11-01: **Grace Hopper** and I went to _Marie's Diner_. George had to cancel at the last minute. @food
- 2015-01-04: Got lunch with **Grace Hopper** and **George Washington Carver**. @food
- 2014-12-31: Celebrated the new year in _Paris_ with **Marie Curie**. @partying
- 2014-11-15: Talked to **George Washington Carver** on the phone for an hour.

### Friends:
- George Washington Carver
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science
- Marie Curie [Atlantis] @science

### Locations:
- Atlantis
- Marie's Diner
- Paris
FILE
    end

    it "prints suggested friends" do
      stdout_only <<-FILE
Distant friend: Marie Curie
Moderate friend: George Washington Carver
Close friend: Grace Hopper
      FILE
    end

    describe "--in" do
      subject { run_cmd("suggest --in Paris") }

      it "prints suggested friends" do
        stdout_only <<-FILE
Distant friend: None found
Moderate friend: None found
Close friend: Grace Hopper
        FILE
      end
    end
  end
end
