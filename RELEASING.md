# Releasing

These are steps for the maintainer to take to release a new version of this gem.

1. On the `master` branch, update the `VERSION` constant in
`lib/friends/version.rb`.
2. Commit the change (`git commit -m 'Bump to vX.X'`).
3. Add a tag (`git tag -am "vX.X" vX.X`).
4. `git push && git push --tags`
5. `github_changelog_generator && git commit -m 'Update CHANGELOG for vX.X'`
6. `git push`
7. `gem build friends.gemspec && gem push *.gem && rm *.gem`
8. Celebrate!
