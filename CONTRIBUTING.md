# Contributing

If you're reading this, it means you want to contribute to this project. Hooray!

Here's what to do:

1. If you're looking for a task to work on, check the
["up-for-grabs" Issues](https://github.com/JacobEvelyn/friends/labels/upforgrabs). If you see something there that catches your
eye, leave a comment indicating you'll work on it and
it's yours! If you already have something to work on,
that's great as well!
2. Fork the repository (https://github.com/JacobEvelyn/friends/fork).
3. Clone your forked repository.
4. From within the repository directory, run:
`bundle install && overcommit --install`
5. Create your feature branch
(`git checkout -b my-new-feature`).
6. Make your changes. Add or modify tests if necessary!
(Run tests with `rake test`.) Do your best to conform to
existing style and commenting patterns.
7. Commit your changes
(`git commit -am "Add some feature"`). You should see
output from
[`overcommit`](https://github.com/brigade/overcommit) as
it runs commit hooks that looks something like this:

  ```
  Running pre-commit hooks
  Analyzing with RuboCop......................................[RuboCop] OK

  ✓ All pre-commit hooks passed

  Running commit-msg hooks
  Checking subject capitalization..................[CapitalizedSubject] OK
  Checking subject line.............................[SingleLineSubject] OK
  Checking text width.......................................[TextWidth] OK
  Checking for trailing periods in subject.............[TrailingPeriod] OK

  ✓ All commit-msg hooks passed
  ```

  If any of the commit hook checks fail, fix them if you
  can but don't hesitate to reach out if you don't know
  how! This practice is meant to keep the code clean but
  it shouldn't be scary and it's totally fine to need
  help!
8. Push your changes to GitHub, and open a Pull Request.
9. Your code will be reviewed and merged as quickly as
possible!
10. Check yourself out on the [contributors page](https://github.com/JacobEvelyn/friends/graphs/contributors)! Look at how cool you are!

If you have any questions at all or get stuck on any step,
don't hesitate to
[open a GitHub Issue](https://github.com/JacobEvelyn/friends/issues/new)!
I'll respond as quickly as I can, and I'm friendly! I
promise I don't bite. 😊
