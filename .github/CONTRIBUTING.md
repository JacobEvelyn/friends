# Contributing

If you're reading this, it means you want to contribute to this project. Hooray!

Here's what to do:

1.  If you're looking for a task to work on, check the
    ["up-for-grabs" issues](https://github.com/JacobEvelyn/friends/labels/upforgrabs). If you see something there that catches your
    eye, leave a comment indicating you'll work on it and
    it's yours! If you already have something to work on,
    that's great as well!
2.  Fork the repository (https://github.com/JacobEvelyn/friends/fork).
3.  Clone your forked repository.
4.  From within the repository directory, run
    `bundle install` to install all dependencies needed for development.
5.  Create your feature branch
    (`git checkout -b my-new-feature`).
6.  Make your changes. Add or modify tests if necessary!
    - Run tests with `bundle exec rake test`. To run a subset of tests:
      1. temporarily add this to `friends.gemspec`:


          ```ruby
          spec.add_development_dependency "minitest-focus"
          ```
      2. Re-run `bundle install` to install `minitest-focus`.
      3. Replace the `it` for the test(s) you want to run with:


          ```ruby
          require "minitest/focus" ; focus ; it
          ```
      4. Run tests as usual with `bundle exec rake test`.
      5. Don't forget to remove these debugging lines when you're done!
    - You can run your version of the `friends` script with `bundle exec bin/friends`.
    - Do your best to conform to existing style and commenting patterns.
7.  Update the `README.md` as necessary to include your changes.
8.  Check your changes for code style by running `bundle exec rubocop .` in
    the repository directory. You may see output indicating that some lines
    differ from the style guidelines. Change your code so that Rubocop gives
    no warnings or errors (and don't hesitate to reach out if you don't know how!—this practice is meant to keep the code clean but it shouldn't be
    scary and it's totally fine to need help!).
9.  Commit your changes
    (`git commit -am "Add some feature"`).
10. Push your changes to GitHub, and open a pull request.
11. Your code will be reviewed and merged as quickly as
    possible!
12. Check yourself out on the [contributors page](https://github.com/JacobEvelyn/friends/graphs/contributors)! Look at how cool you are!

If you have any questions at all or get stuck on any step,
don't hesitate to
[open a GitHub issue](https://github.com/JacobEvelyn/friends/issues/new)!
I'll respond as quickly as I can, and I'm friendly! I
promise I don't bite. 😊

## Code of Conduct

Note that this project follows a [Code of Conduct](https://github.com/JacobEvelyn/friends/blob/master/CODE_OF_CONDUCT.md).
If you're a polite, reasonable person you won't have any issues!

## Financial contributions

`friends` is a volunteer project. If you find it valuable, please consider
making a small donation (🙏) with the **Sponsor** button at the top of this page
to show you appreciate its continued development.

## Contributors

Thank you to all the lovely people who have already contributed to `friends`!
You folks make `friends` great.
<a href="graphs/contributors"><img src="https://opencollective.com/friends/contributors.svg?width=890" /></a>
