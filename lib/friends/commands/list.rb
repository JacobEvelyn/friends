# frozen_string_literal: true

desc "Lists friends, activities, and locations"
command :list do |list|
  list.desc "List all friends"
  list.command :friends do |list_friends|
    list_friends.flag [:in],
                      arg_name: "LOCATION",
                      desc: "List only friends in the given location",
                      type: Stripped

    list_friends.flag [:tagged],
                      arg_name: "@TAG",
                      desc: "List only friends with the given tag",
                      type: Tag,
                      multiple: true

    list_friends.switch [:verbose],
                        negatable: false,
                        desc: "Output friend nicknames, locations, and tags"

    list_friends.flag :sort,
                      default_value: "alphabetical",
                      arg_name: "ATTRIBUTE",
                      must_match: %w[alphabetical n-activities recency],
                      desc: "Sort output by one of: alphabetical, n-activities, recency"

    list_friends.switch :reverse,
                        negatable: false,
                        desc: "Reverse the sort order"

    list_friends.action do |_, options|
      @introvert.list_friends(
        location_name: options[:in],
        tagged: options[:tagged],
        verbose: options[:verbose],
        sort: options[:sort],
        reverse: options[:reverse]
      )
    end
  end

  [:activities, :notes].each do |events|
    list.desc "Lists all #{events}"
    list.command events do |list_events|
      list_events.flag [:with],
                       arg_name: "NAME",
                       desc: "List only #{events} with the given friend",
                       type: Stripped,
                       multiple: true

      list_events.flag [:in],
                       arg_name: "LOCATION",
                       desc: "List only #{events} in the given location",
                       type: Stripped

      list_events.flag [:tagged],
                       arg_name: "@TAG",
                       desc: "List only #{events} with the given tag",
                       type: Tag,
                       multiple: true

      list_events.flag [:since],
                       arg_name: "DATE",
                       desc: "List only #{events} on or after the given date",
                       type: InputDate

      list_events.flag [:until],
                       arg_name: "DATE",
                       desc: "List only #{events} before or on the given date",
                       type: InputDate

      list_events.action do |_, options|
        @introvert.send(
          "list_#{events}",
          with: options[:with],
          location_name: options[:in],
          tagged: options[:tagged],
          since_date: options[:since],
          until_date: options[:until]
        )
      end
    end
  end

  list.desc "List all locations"
  list.command :locations do |list_locations|
    list_locations.switch [:verbose],
                          negatable: false,
                          desc: "Output location aliases"

    list_locations.flag :sort,
                        default_value: "alphabetical",
                        arg_name: "ATTRIBUTE",
                        must_match: %w[alphabetical n-activities recency],
                        desc: "Sort output by one of: alphabetical, n-activities, recency"

    list_locations.switch :reverse,
                          negatable: false,
                          desc: "Reverse the sort order"

    list_locations.action do |_, options|
      @introvert.list_locations(
        verbose: options[:verbose],
        sort: options[:sort],
        reverse: options[:reverse]
      )
    end
  end

  list.desc "List all tags used"
  list.command :tags do |list_tags|
    list_tags.flag [:from],
                   arg_name: '"activities" or "friends" or "notes" (default: all)',
                   desc: "List only tags from activities, friends, or notes instead of"\
                         "all three",
                   multiple: true
    list_tags.action do |_, options|
      @introvert.list_tags(from: options[:from])
    end
  end
end
