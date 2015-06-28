[![Code Climate](https://codeclimate.com/github/JacobEvelyn/friends/badges/gpa.svg)](https://codeclimate.com/github/JacobEvelyn/friends) [![Test Coverage](https://codeclimate.com/github/JacobEvelyn/friends/badges/coverage.svg)](https://codeclimate.com/github/JacobEvelyn/friends) [![Build Status](https://travis-ci.org/JacobEvelyn/friends.svg)](https://travis-ci.org/JacobEvelyn/friends) [![Inline docs](http://inch-ci.org/github/JacobEvelyn/friends.png)](http://inch-ci.org/github/JacobEvelyn/friends)

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
  - A way to track of the ebbs and flows of your relationships over
    time.
  - Suggestions for who to call or hang out with when you have free
    time, whether it's fifteen minutes or an entire weekend.
  - A low-cost way to record and remember big moments in your life.
2. **Friends** stores its data in a universally readable `friends.md`
  Markdown file. No proprietary formats here!
3. **Friends** is open-source and very open to new ideas. Contribute!

## Installation

```
$ gem install friends
```

## Usage

### Basic commands:

Add a friend:

```
$ friends add friend "Grace Hopper"
Friend added: "Grace Hopper"
```
List your friends:
```
$ friends list friends
George Washington Carver
Grace Hopper
Marie Curie
```
Record an activity with a friend:
```
$ friends add activity "Got lunch with Grace and George."
Activity added: "2015-01-04: Got lunch with Grace Hopper and George Washington Carver."
```
Or specify a date for the activity:
```
$ friends add activity "2014-12-31: Celebrated the new year with Marie."
Activity added: "2014-12-31: Celebrated the new year with Marie Curie."
```
List the activities you've recorded:
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
Find your favorite friends:
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

### Global options:

##### --quiet

Quiet output messages:
```
$ friends add activity "Went rollerskating with George."
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
[documentation](http://www.rubydoc.info/JacobEvelyn/friends).

## Contributing

If you have an idea,
[make a GitHub Issue](https://github.com/JacobEvelyn/friends/issues/new)!
Suggestions are very very welcome, and often are implemented very
quickly. And if you'd like to do the implementing yourself:

1. Fork it (https://github.com/JacobEvelyn/friends/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

**Make sure your changes have appropriate tests (`rake test`) and
conform to the Rubocop style specified. This project uses
[overcommit](https://github.com/causes/overcommit) to enforce good
code.**

## License

Friends is released under the
[MIT License](https://github.com/JacobEvelyn/friends/blob/master/LICENSE.txt).
