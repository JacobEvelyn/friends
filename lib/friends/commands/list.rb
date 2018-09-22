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

    list_friends.action do |_, options|
      @introvert.list_friends(
        location_name: options[:in],
        tagged: options[:tagged],
        verbose: options[:verbose]
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
    list_locations.action do
      @introvert.list_locations
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

  list.desc "List favorite friends and locations"
  list.command :favorite do |list_favorite|
    list_favorite.desc "List favorite friends"
    list_favorite.command :friends do |list_favorite_friends|
      list_favorite_friends.action do
        @introvert.list_favorite_friends
      end
    end

    list_favorite.desc "List favorite locations"
    list_favorite.command :locations do |list_favorite_locations|
      list_favorite_locations.action do
        @introvert.list_favorite_locations
      end
    end
  end
end
