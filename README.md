[![Gem Version](https://badge.fury.io/rb/friends.svg)](https://badge.fury.io/rb/friends) [![Dependency Status](https://gemnasium.com/badges/github.com/JacobEvelyn/friends.svg)](https://gemnasium.com/github.com/JacobEvelyn/friends)
 [![Coverage Status](https://coveralls.io/repos/github/JacobEvelyn/friends/badge.svg)](https://coveralls.io/github/JacobEvelyn/friends) [![Build Status](https://travis-ci.org/JacobEvelyn/friends.svg?branch=master)](https://travis-ci.org/JacobEvelyn/friends) [![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=JacobEvelyn/friends&bust=1)](http://clayallsopp.github.io/readme-score?url=JacobEvelyn/friends) [![Inline docs](http://inch-ci.org/github/JacobEvelyn/friends.png)](http://inch-ci.org/github/JacobEvelyn/friends) [![ghit.me](https://ghit.me/badge.svg?repo=JacobEvelyn/friends)](https://ghit.me/repo/JacobEvelyn/friends)

# `friends`

Spend time with the people you care about. Introvert-tested.
Extrovert-approved.

**NOTE: Participation is encouraged! Make Issues, ask questions, submit Pull
Requests (even if it's your first time contributing to open-source—you'll get
lots of help), and give feedback!**

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
  - [Core concepts](#core-concepts)
  - [Global flags](#global-flags)
  - [Syncing across multiple machines](#syncing-across-multiple-machines)
  - [Setting reminders](#setting-reminders)
  - [Command reference](#command-reference)
    - `add`
      - [`add activity`](#add-activity)
      - [`add friend`](#add-friend)
      - [`add tag`](#add-tag)
      - [`add location`](#add-location)
      - [`add nickname`](#add-nickname)
    - [`clean`](#clean)
    - [`graph`](#graph)
    - [`help`](#help)
    - `list`
      - [`list activities`](#list-activities)
      - `list favorite`
        - [`list favorite friends`](#list-favorite-friends)
        - [`list favorite locations`](#list-favorite-locations)
      - [`list friends`](#list-friends)
      - [`list tags`](#list-tags)
      - [`list locations`](#list-locations)
    - `remove`
      - [`remove tag`](#remove-tag)
      - [`remove nickname`](#remove-nickname)
    - `rename`
      - [`rename friend`](#rename-friend)
      - [`rename location`](#rename-location)
    - [`set location`](#set-location)
    - [`stats`](#stats)
    - [`suggest`](#suggest)
    - [`update`](#update)
- [Other documentation](#other-documentation)
- [Contributing (it's encouraged!)](#contributing-its-encouraged)
- [Code of Conduct](#code-of-conduct)
- [License](#license)

----

## Overview

`friends` is a command-line program that helps you to keep track of your relationships with the
people you care about.

`friends` gives you:
- More organization around staying in touch with friends and
  family.
- A way to track the ebbs and flows of your relationships over
  time.
- Suggestions for who to call or hang out with when you have free
  time, whether it's fifteen minutes or an entire weekend.
- A low-cost way to record and remember big moments in your life.

Its philosophy emphasizes:

- **Simplicity**—it should be quick and easy to use.
- **Transparency**—all data is stored in a human-readable Markdown file. No
  proprietary formats here! And in addition to being open-source, `friends` is
  very much open to new ideas. Contribute!
- **Intelligence**—specify dates with English phrases like "yesterday." Specify
  friends with their first names, even when you're friends with many *Joanne*s. `friends` will figure it out.

## Installation

```
$ gem install friends
```

Easy, huh?

## Usage

### Core concepts

`friends` is structured around several different types of things:

- **Activities**: The things you do. Each activity has a date associated with
  it. Activities may optionally contain any number of *friends*, *locations*,
  and *tags*.
- **Friends**: The people you do *activities* with. Each friend has a name and,
  optionally, one or several nicknames. (Examples: `John`, `Grace Hopper`)
- **Locations**: The places in which *activities* happen. (Examples: `Paris`,
  `Marie's Diner`)
- **Tags**: A way to categorize your *activities* with tags of your
  choosing. (Examples: `@exercise`, `@school`)

The `friends.md` Markdown file that stores all of your data contains:

- an alphabetical list of all locations:

```markdown
### Locations:
- Atlantis
- Marie's Diner
- Paris
```

- an alphabetical list of all friends and their nicknames and locations:

```markdown
### Friends:
- George Washington Carver
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris]
- Marie Curie [Atlantis]
```

- and an ordered list of all activities:

```markdown
### Activities:
- 2018-11-01: **Grace Hopper** and I went to _Marie's Diner_. George had to cancel at the last minute.
- 2018-01-04: Got lunch with **Grace Hopper** and **George Washington Carver**.
- 2017-12-31: Celebrated the new year in _Paris_ with **Marie Curie**.
- 2017-11-15: Talked to **George Washington Carver** on the phone for an hour.
```

See the example
[`friends.md`](https://github.com/JacobEvelyn/friends/blob/master/friends.md)
file for more information.

### Global flags

`friends` supports several global flags that can be used on any command when
specified before the name of the command, like: `friends [flags] [command]`.

These flags are:

- `--colorless`: Disable output colorization and other effects.
- `--debug`: Debug error messages with a full backtrace.
- `--filename`: Set the location of the friends file to use (default: ./friends.md).

```bash
$ friends --filename ./test/tmp/friends.md clean
File cleaned: "./test/tmp/friends.md"
```

- `--quiet`: Quiet output messages.

```bash
$ friends --quiet add activity Went rollerskating with George.
$ # No output!
```

In addition, these flags may be used without any command:

- `--help`: Show the help menu. This is equivalent to `friends help`.
Help menus are available for all levels of commands:

```bash
$ friends --help
```

```bash
$ friends list --help
```

```bash
$ friends list activities --help
```

- `--version`: Show the `friends` program version.

### Syncing across multiple machines

Wouldn't it be nice to be able to use `friends` across all of your
devices? Hooray, you can! Just put the `friends.md` file in your
Dropbox/Box Sync/Google Drive/whatever folder and use the
`--filename` flag. You can even set up a Bash/Zsh/whatever alias to
do this for you, like so:

```bash
alias friends="friends --filename '~/Dropbox/friends.md'"
```

### Setting reminders

Though `friends` has no built-in reminder functionality, it's easy to use a
system like `cron` (Mac or Linux) or `Task Scheduler` (Windows) to set various
reminders.

For example, on a Mac, the following `crontab` configuration results in every day
at 9:00 p.m. a Terminal tab opening, printing "Time to journal!" and then launching
an `add activity` prompt through `friends`:

```
0 21 * * * osascript -e 'activate application "Terminal"' &> /dev/null && osascript -e 'tell application "Terminal" to do script "clear && echo Time to journal! && friends add activity"' &> /dev/null
```

Here's another example (also for Mac) of using `friends` to suggest some people to
hang out with every Saturday morning:

```
0 10 * * 6 osascript -e 'activate application "Terminal"' &> /dev/null && osascript -e 'tell application "Terminal" to do script "clear && echo Consider hanging out with one of these friends today: && friends suggest"' &> /dev/null
```

(If you use other tools, please share and we'll add to these examples!)

### Command reference*

*Note that the command-line output is colored, which this README cannot show.

#### `add activity`

```bash
$ friends add activity Got lunch with Grace and George.
Activity added: "2018-01-04: Got lunch with Grace Hopper and George Washington Carver."
```

`friends` will **automatically** figure out which "Grace" and "George" you're referring to, *even if you're friends with lots of different Graces and Georges*.

Nicknames will be used to match friends in activities,
just like formal names:

```bash
$ friends add activity Invented debugging with The Admiral.
Activity added: "2017-01-06: Invented debugging with Grace Hopper."
```

You can also use the first initial of a last name instead of the whole thing.
`friends` will figure out what to do with those pesky periods (if you include
them) based on whether you're in the middle of a sentence or not:

```bash
$ friends add activity Got lunch with Earnest H and Earnest S. in the park. Man, I like Earnest H. but really love Earnest S.
Activity added: "2017-05-01: Got lunch with Earnest Hemingway and Earnest Shackleton in the park. Man, I like Earnest Hemingway but really love Earnest Shackleton."
```

And locations will be matched as well:

```bash
$ friends add activity Went swimming near atlantis with George.
Activity added: "2017-01-06: Went swimming near Atlantis with George Washington Carver."
```

Tags will be colored if they're provided (though this README can't display
color so you'll just have to have faith here):

```bash
$ friends add activity The office softball team wins a game! @work @exercise
Activity added: "2017-05-05: The office softball team wins a game! @work @exercise"
```

You can of course specify a date for the activity:

```bash
$ friends add activity Yesterday: Celebrated the new year with Marie.
Activity added: "2017-12-31: Celebrated the new year with Marie Curie."
```

Or get an **interactive prompt** by just typing `friends add activity`, with or without a date specified:

```bash
$ friends add activity 2018-11-01
2018-11-01: <type description here>
```

**Natural-language dates** work just fine:

```bash
$ friends add activity last Monday
2017-03-07: <type description here>
```

You can escape the names of friends you don't want `friends` to match with a backslash:

```bash
$ friends add activity "2018-11-01: Grace and I went to \Marie's Diner. \George had to cancel at the last minute."
Activity added: "2018-11-01: Grace Hopper and I went to Marie's Diner. George had to cancel at the last minute."
```

#### `add friend`

```bash
$ friends add friend Grace Hopper
Friend added: "Grace Hopper"
```

#### `add tag`

```bash
$ friends add tag Grace Hopper science
Tag added to friend: "Grace Hopper @science"
```

#### `add location`

```
$ friends add location Atlantis
Location added: "Atlantis"
```

#### `add nickname`

```bash
$ friends add nickname "Grace Hopper" "The Admiral"
Nickname added: "Grace Hopper (a.k.a. The Admiral)
$ friends add nickname "Grace Hopper" "Amazing Grace"
Nickname added: "Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace)"
```

#### `clean`

Reads and re-writes the `friends.md` file:

```bash
$ friends clean
File cleaned: "./friends.md"
```

This command is useful after manual editing of the file, for re-ordering its
contents.

#### `edit`

Allows you to manually edit the file:

```bash
$ friends edit
Opening "./friends.md" in vim
```

The file is opened with the command specified by the `$EDITOR` environment
variable, falling back to `vim` if it is not set:

```bash
$ export EDITOR=atom
$ friends edit
Opening "./friends.md" in atom
```

#### `graph`

Graphs (in color!) your activities over time:

```bash
$ friends graph
Nov 2017 |███
Dec 2017 |██
Jan 2018 |███████
Feb 2018 |█████
```

Or graph only activities with a certain friend:

```bash
$ friends graph --with George
Nov 2017 |█∙∙|
Dec 2017 |∙∙|
Jan 2018 |█████∙∙|
Feb 2018 |███∙∙|
```

The dots represent the total activities that month, so you can get a feel for the
proportion of activities with that friend vs. the total you've logged.

You can also graph a certain group of friends:

```bash
$ friends graph --with George --with Grace
Nov 2017 |∙∙∙|
Dec 2017 |∙∙|
Jan 2018 |█∙∙∙∙∙∙|
Feb 2018 |∙∙∙∙∙|
```

Or graph only activities with a certain tag:

```bash
$ friends graph --tagged food
Nov 2017 |█∙∙|
Dec 2017 |∙∙|
Jan 2018 |∙∙∙∙∙∙∙|
Feb 2018 |███∙∙|
```

Or with multiple tags:

```bash
$ friends graph --tagged @fun --tagged @work
Nov 2017 |∙∙∙|
Dec 2017 |█∙|
Jan 2018 |∙∙∙∙∙∙∙|
Feb 2018 |█∙∙∙∙|
```

Or graph only activities in a certain location:

```bash
$ friends graph --in Paris
Nov 2017 |█∙∙|
Dec 2017 |∙∙|
Jan 2018 |∙∙∙∙∙∙∙|
Feb 2018 |█∙∙∙∙|
```

Or graph only activities on or after a certain date:

```bash
$ friends graph --since 'January 1st 2018'
Jan 2018 |███████
Feb 2018 |█████
```

Or graph only activities before or on a certain date:

```bash
$ friends graph --until 'January 1st 2018'
Nov 2017 |███
Dec 2017 |██
Jan 2018 |███████
```

And you can use multiple of these flags together:

```bash
$ friends graph --in Paris --tagged food --with George --since 'Jan 2018'
Jan 2018 |∙∙∙∙∙∙∙|
Fen 2017 |█∙∙∙∙|
```

#### `help`

Displays a help menu. This is equivalent to `friends --help`.

```bash
$ friends help
NAME
    friends - Spend time with the people you care about. Introvert-tested. Extrovert-approved.

SYNOPSIS
    friends [global options] command [command options] [arguments...]

...
```

Help menus are available for all levels of commands:

```bash
$ friends help
```

```bash
$ friends help list
```

```bash
$ friends help list activities
```

#### `list activities`

Lists recent activities:

```bash
$ friends list activities
2018-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
2017-12-31: Celebrated the new year with Marie Curie in New York City. @partying
2017-11-15: Talked to George Washington Carver on the phone for an hour.
```

You can adjust how many activities are shown:

```bash
$ friends list activities --limit 2
2018-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
2017-12-31: Celebrated the new year with Marie Curie in New York City. @partying
```

Or only list the activities you did with a certain friend:

```bash
$ friends list activities --with George
2018-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
2017-11-15: Talked to George Washington Carver on the phone for an hour.
```

Or only filter activities done with a group of friends:

```bash
$ friends list activities --with George --with Grace
2018-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
```

Or filter your activities by location:

```bash
$ friends list activities --in "New York"
2017-12-31: Celebrated the new year with Marie Curie in New York City. @partying
```

Or by tag:

```bash
$ friends list activities --tagged food
2018-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
```

Or use more than one tag:

```bash
$ friends list activities --tagged @fun --tagged @work
2018-07-04: Summer picnic with @work colleagues. @fun
```

Or by date:

```bash
$ friends list activities --since 'December 31st 2017'
2018-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
2017-12-31: Celebrated the new year with Marie Curie in New York City. @partying
```

```bash
$ friends list activities --until 'December 31st 2017'
2017-12-31: Celebrated the new year with Marie Curie in New York City. @partying
2017-11-15: Talked to George Washington Carver on the phone for an hour.
```

And you can mix and match these options to your heart's content:

```bash
$ friends list activities --tagged food --with Grace --with George
2018-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
```

#### `list favorite friends`

Lists your "favorite" friends (by total number of activities):

```bash
$ friends list favorite friends
Your favorite friends:
1. George Washington Carver (2 activities)
2. Grace Hopper             (1)
3. Marie Curie              (0)
```

You can specify a number of favorites to show:

```bash
$ friends list favorite friends --limit 2
Your favorite friends:
1. George Washington Carver (2 activities)
2. Grace Hopper             (1)
```

#### `list favorite locations`

Lists your "favorite" locations (by total number of activities):

```bash
$ friends list favorite locations
Your favorite locations:
1. Atlantis (2 activities)
2. Paris    (1)
3. London   (0)
```

You can specify a number of favorites to show:

```bash
$ friends list favorite locations --limit 2
Your favorite locations:
1. Atlantis (2 activities)
2. Paris    (1)
```

#### `list friends`

Lists all of your friends in alphabetical order:

```bash
$ friends list friends
George Washington Carver
Grace Hopper
Marie Curie
```

You can also include friend nicknames, locations, and tags:

```bash
$ friends list friends --verbose
George Washington Carver
Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science
Marie Curie [Atlantis] @science
```

You can filter your friends by location:

```bash
$ friends list friends --in Paris
Marie Curie
```

And you can also filter your friends by tag:

```bash
$ friends list friends --tagged science
Grace Hopper
Marie Curie
```

You can even use more than one tag to further narrow down the list:

```bash
$ friends list friends --tagged science --tagged navy
Grace Hopper
```

#### `list tags`

Lists all tags you've used, in alphabetical order:

```bash
$ friends list tags
@dancing
@food
@school
@swanky
```

You can limit this to only tags from activities:

```bash
$ friends list tags --from activities
@dancing
@food
@swanky
```

Or only tags from friends:

```bash
$ friends list tags --from friends
@school
@swanky
```

#### `list locations`

Lists all of the locations you've added, in alphabetical order::

```
$ friends list locations
Atlantis
New York City
Paris
```

#### `remove tag`

Removes a specific tag from a friend:

```bash
$ friends remove tag Grace Hopper fun
Tag removed from friend: "Grace Hopper (a.k.a. Amazing Grace) @OtherTag"
```

#### `remove nickname`

Removes a specific nickname from a friend:

```bash
$ friends remove nickname "Grace Hopper" "The Admiral"
Nickname removed: "Grace Hopper (a.k.a. Amazing Grace)"
```

#### `rename friend`

```bash
$ friends rename friend "Grace Hopper" "Grace Brewster Murray Hopper"
Name changed: "Grace Brewster Murray Hopper (a.k.a. Amazing Grace)"
```

#### `rename location`

```bash
$ friends rename location Paris "Paris, France"
Location renamed: "Paris, France"
```

#### `set location`

Sets a friend's location:

```bash
$ friends set location Marie Paris
Marie Curie's location set to: Paris
```

#### `stats`

Gives you your lifetime usage stats:

```bash
$ friends stats
Total activities: 4
Total friends: 3
Total time elapsed: 5 days
```

#### `suggest`

Gives you suggestions of up to three random friends to do something with, based
on how often you've done things with them in the past:

```bash
$ friends suggest
Distant friend: Marie Curie
Moderate friend: Grace Hopper
Close friend: George Washington Carver
```

You can request suggestions of friends in a specific location:

```bash
$ friends suggest --in Paris
Distant friend: Marie Curie
```

#### `update`

Updates `friends` to the latest version on RubyGems:

```
$ friends update
Updated to friends 0.17
```

## Other documentation

In case you're *really* interested, we have documentation on
[RubyDoc](http://www.rubydoc.info/github/JacobEvelyn/friends).

## Contributing (it's encouraged!)

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
