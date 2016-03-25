[![Gem Version](https://badge.fury.io/rb/friends.svg)](https://badge.fury.io/rb/friends) [![Code Climate](https://codeclimate.com/github/JacobEvelyn/friends/badges/gpa.svg)](https://codeclimate.com/github/JacobEvelyn/friends) [![Test Coverage](https://codeclimate.com/github/JacobEvelyn/friends/badges/coverage.svg)](https://codeclimate.com/github/JacobEvelyn/friends) [![Build Status](https://travis-ci.org/JacobEvelyn/friends.svg?branch=master)](https://travis-ci.org/JacobEvelyn/friends) [![Inline docs](http://inch-ci.org/github/JacobEvelyn/friends.png)](http://inch-ci.org/github/JacobEvelyn/friends) [![ghit.me](https://ghit.me/badge.svg?repo=JacobEvelyn/friends)](https://ghit.me/repo/JacobEvelyn/friends)

# Friends

Spend time with the people you care about. Introvert-tested.
Extrovert-approved.

### What is it?

**Friends** is both a Ruby library and a command-line interface that
allows you to keep track of your relationships with the people you
care about.

### Why use it?

1. **Friends** gives you:
  - More organization around staying in touch with friends and
    family.
  - A way to track the ebbs and flows of your relationships over
    time.
  - Suggestions for who to call or hang out with when you have free
    time, whether it's fifteen minutes or an entire weekend.
  - A low-cost way to record and remember big moments in your life.
2. **Friends** stores its data in a human-readable `friends.md`
  Markdown file. No proprietary formats here!
3. **Friends** is open-source and very open to new ideas. Contribute!

## Installation

```
$ gem install friends
```

## Usage*

*Note that the command-line output is colored, which this README cannot show.

### Basic commands:

##### Add a friend:
```
$ friends add friend "Grace Hopper"
Friend added: "Grace Hopper"
```
##### Record an activity with a friend:
```
$ friends add activity "Got lunch with Grace and George."
Activity added: "2015-01-04: Got lunch with Grace Hopper and George Washington Carver."
```
`friends` will **automatically** figure out which "Grace" and "George" you're referring to, *even if you're friends with lots of different Graces and Georges*.

You can of course specify a date for the activity:
```
$ friends add activity "Yesterday: Celebrated the new year with Marie."
Activity added: "2014-12-31: Celebrated the new year with Marie Curie."
```
Or get an **interactive prompt** by just typing `friends add activity`, with or without a date specified:
```
$ friends add activity 2015-11-01
2015-11-01: <type description here>
```
**Natural-language dates** work just fine:
```
$ friends add activity 'last Monday'
2016-03-07: <type description here>
```
You can escape the names of friends you don't want `friends` to match with a backslash:
```
$ friends add activity "2015-11-01: Grace and I went to \Marie's Diner. \George had to cancel at the last minute."
Activity added: "2015-11-01: Grace Hopper and I went to Marie's Diner. George had to cancel at the last minute."
```
##### Set a friend's nicknames:
```
$ friends add nickname "Grace Hopper" "The Admiral"
Nickname added: "Grace Hopper (a.k.a. The Admiral)
$ friends add nickname "Grace Hopper" "Amazing Grace"
Nickname added: "Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace)"
```
Nicknames will be used to match friends in activities,
just like formal names:
```
$ friends add activity "Invented debugging with Amazing Grace.""
Activity added: "2016-01-06: Invented debugging with Amazing Grace Hopper."
```
And they can be removed as well:
```
$ friends remove nickname "Grace Hopper" "The Admiral"
Nickname removed: "Grace Hopper (a.k.a. Amazing Grace)"
```
##### Change a friend's name:
```
$ friends rename friend "Grace Hopper" "Grace Brewster Murray Hopper"
Name changed: "Grace Brewster Murray Hopper (a.k.a. Amazing Grace)"
```
##### Suggest a friend to do something with:
```
$ friends suggest
Distant friend: Marie Curie
Moderate friend: Grace Hopper
Close friend: George Washington Carver
```
##### List the activities you've recorded:
```
$ friends list activities
2015-01-04: Got lunch with Grace Hopper and George Washington Carver.
2014-12-31: Celebrated the new year with Marie Curie.
2014-11-15: Talked to George Washington Carver on the phone for an hour.
```
Or only list the activities you did with a certain friend:
```
$ friends list activities --with "George"
2015-01-04: Got lunch with Grace Hopper and George Washington Carver.
2014-11-15: Talked to George Washington Carver on the phone for an hour.

```
##### Find your favorite friends:
```
$ friends list favorites
Your favorite friends:
1. George Washington Carver (2 activities)
2. Grace Hopper             (1)
3. Marie Curie              (1)
```
Or get a specific number of favorites:
```
$ friends list favorites --limit 2
Your favorite friends:
1. George Washington Carver (2 activities)
2. Grace Hopper             (1)
```
##### Graph (in color!) your relationship with a friend over time:
```
$ friends graph George
Nov 2014 |█
Dec 2014 |
Jan 2015 |█████
Feb 2015 |███
```
##### Or just graph all of your activities:
```
$ friends graph
Nov 2014 |███
Dec 2014 |██
Jan 2015 |███████
Feb 2015 |█████
```
##### Or just check out your lifetime stats:
```
$ friends stats
Total activities: 4
Total friends: 3
Total time elapsed: 5 days
```
##### List all of your friends:
```
$ friends list friends
George Washington Carver
Grace Hopper
Marie Curie
```
##### Update to the latest version:
```
$ friends update
Updated to friends 0.3
```
### Global options:

##### --quiet

Quiet output messages:
```
$ friends --quiet add activity "Went rollerskating with George."
$ # No output!
```

##### --filename

Change the location/name of the `friends.md` file:
```
$ friends --filename ./test/tmp/friends.md clean
File cleaned: "./test/tmp/friends.md"
```

##### --clean

Force cleaning of the `friends.md` file, even if the command does not
normally write to the file.
```
$ friends --clean list friends
George Washington Carver
Grace Hopper
Marie Curie
File cleaned: "./friends.md"
```

### Advanced usage:

Wouldn't it be nice to be able to use **Friends** across all of your
devices? Hooray, you can! Just put the `friends.md` file in your
Dropbox/Box Sync/Google Drive/whatever folder and use the
`--filename` flag. You can even set up a Bash/Zsh/whatever alias to
do this for you, like so:
```bash
alias friends="friends --filename '~/Dropbox/friends.md'"
```

### Help:

Help menus are available for all levels of commands:
```
$ friends --help
```
```
$ friends list --help
```
```
$ friends list activities --help
```

## Documentation

In case you're *really* interested, we have
[documentation](http://www.rubydoc.info/github/JacobEvelyn/friends).

## Contributing

If you have an idea,
[make a GitHub Issue](https://github.com/JacobEvelyn/friends/issues/new)!
Suggestions are very very welcome, and usually are implemented very
quickly. And if you'd like to do the implementing yourself, see the
[contributing guide](https://github.com/JacobEvelyn/friends/blob/master/CONTRIBUTING.md).

A big big thanks to all of this project's lovely
[contributors](https://github.com/JacobEvelyn/friends/graphs/contributors)!

## Code of Conduct

Note that this project follows a [Code of Conduct](https://github.com/JacobEvelyn/friends/blob/master/CODE_OF_CONDUCT.md).
If you're a polite, reasonable person you won't have any issues!

## License

Friends is released under the
[MIT License](https://github.com/JacobEvelyn/friends/blob/master/LICENSE.txt).
