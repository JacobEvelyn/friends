# Releasing

These are steps for the maintainer to take to release a new version of this gem.

1.  On the `main` branch, update the `VERSION` constant in
    `lib/friends/version.rb`.
2.  Commit the change (`git add -A && git commit -m 'Bump to vX.X'`).
3.  Add a tag (`git tag -am "vX.X" vX.X`).
4.  `git push && git push --tags`
5.  Copy the top of `CHANGELOG` to the clipboard.
6.  `CHANGELOG_GITHUB_TOKEN=... github_changelog_generator --user JacobEvelyn --project friends`
7.  Paste from the clipboard to the top of the `CHANGELOG`.
8.  Confirm the `CHANGELOG` looks correct with `git diff`
9.  `git add -A && git commit -m 'Update CHANGELOG for vX.X'`
10. `git push`
11. `gem build friends.gemspec && gem push *.gem && rm *.gem`
12. Celebrate!
