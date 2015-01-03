[![Code Climate](https://codeclimate.com/github/JacobEvelyn/friends/badges/gpa.svg)](https://codeclimate.com/github/JacobEvelyn/friends) [![Test Coverage](https://codeclimate.com/github/JacobEvelyn/friends/badges/coverage.svg)](https://codeclimate.com/github/JacobEvelyn/friends) [![Build Status](https://travis-ci.org/JacobEvelyn/friends.svg)](https://travis-ci.org/JacobEvelyn/friends) [![Inline docs](http://inch-ci.org/github/JacobEvelyn/friends.png)](http://inch-ci.org/github/JacobEvelyn/friends)

# Friends

Spend time with the people you care about. Introvert-tested. Extrovert-approved.

## Installation

    $ gem install friends

## Usage

Add your friends:

    $ friends add friend "Jacob Evelyn"
    Friend added: "Jacob Evelyn"

    $ friends add friend "Betsy Ross"
    Friend added: "Betsy Ross"

    $ friends list friends
    Betsy Ross
    Jacob Evelyn

Record things you do with them:

    $ friends add activity "2014-12-31: Celebrated the new year with Betsy."
    Activity added: "2014-12-31: Celebrated the new year with Betsy Ross."

    $ friends add activity "2015-01-01: Got lunch with Jacob and Betsy."
    Activity added: "2015-01-01: Got lunch with Jacob Evelyn and Betsy Ross."

    $ friends list activities
    2014-01-02: Got lunch with Jacob Evelyn and Betsy Ross.
    2014-12-31: Celebrated the new year with Betsy Ross.

Need help?

    $ friends --help

## Documentation

In case you're really interested, we have
[documentation](http://www.rubydoc.info/JacobEvelyn/friends).

## Contributing

If you have an idea, make an Issue! Suggestions are very very welcome,
and may be implemented quickly. If you'd like to do the implementing
yourself:

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
