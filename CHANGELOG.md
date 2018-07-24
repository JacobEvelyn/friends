# Change Log

`friends` is a volunteer project. If you find it useful, please consider
making a small donation (🙏) to show you appreciate its continued development.

👇 Donate with these buttons! 👇

[![Backers on Open Collective](<https://opencollective.com/friends/backers_(Open_Collective)/badge.svg>)](https://opencollective.com/friends#backer) [![Sponsors on Open Collective](<https://opencollective.com/friends/sponsors_(Open_Collective)/badge.svg>)](https://opencollective.com/friends#sponsor)
[![Support via Patreon](https://img.shields.io/badge/support-Patreon-green.svg)](https://www.patreon.com/jacobevelyn)
[![Donate via Liberapay](https://img.shields.io/badge/donate-Liberapay-green.svg)](https://liberapay.com/jacobevelyn/donate)
[![Donate via PayPal](https://img.shields.io/badge/donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=jacobevelyn%40gmail%2ecom&lc=US&item_name=Development%20of%20JacobEvelyn%2ffriends%20%28GitHub%20repository%29&no_note=0¤cy_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHostedGuest)
[![Flattr this](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=jacobevelyn&url=https://github.com/JacobEvelyn/friends&title=friends&tags=github&category=software)
[![Donate bitcoin](https://img.shields.io/badge/donate-Bitcoin-green.svg)](https://nrobinson2000.github.io/donate-bitcoin?address=1CFu6gWpmS89EnitPPdYssZhFMRWx5qhW4&amount=10&name=support-friends-development)

👆 Donate with these buttons! 👆

## [v0.38](https://github.com/JacobEvelyn/friends/tree/v0.38) (2018-07-24)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.37...v0.38)

**Implemented enhancements:**

- Give matching priority to first name-only people [\#202](https://github.com/JacobEvelyn/friends/issues/202)
- Don't allow blank activities, friend names, tags, locations, or notes [\#198](https://github.com/JacobEvelyn/friends/issues/198)

**Merged pull requests:**

- Give name-matching priority to full-text matches [\#203](https://github.com/JacobEvelyn/friends/pull/203) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Prevent the addition of blank events, names, and locations [\#200](https://github.com/JacobEvelyn/friends/pull/200) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Fix Rubocop errors [\#196](https://github.com/JacobEvelyn/friends/pull/196) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Update rake requirement to ~\> 12.3 [\#194](https://github.com/JacobEvelyn/friends/pull/194) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v0.37](https://github.com/JacobEvelyn/friends/tree/v0.37) (2018-02-24)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.36...v0.37)

**Implemented enhancements:**

- Allow \(some\) punctuation in tags [\#186](https://github.com/JacobEvelyn/friends/issues/186)

**Merged pull requests:**

- Activating Open Collective [\#193](https://github.com/JacobEvelyn/friends/pull/193) ([monkeywithacupcake](https://github.com/monkeywithacupcake))
- Dashes and colons [\#191](https://github.com/JacobEvelyn/friends/pull/191) ([adiabatic](https://github.com/adiabatic))

## [v0.36](https://github.com/JacobEvelyn/friends/tree/v0.36) (2018-01-17)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.35...v0.36)

**Implemented enhancements:**

- Parse friends.md and generate lists of friends/locations from the activities [\#182](https://github.com/JacobEvelyn/friends/issues/182)

**Fixed bugs:**

- `rename friend` and `rename location` do not correctly update existing notes [\#189](https://github.com/JacobEvelyn/friends/issues/189)

**Closed issues:**

- Add `grep` examples to the README [\#183](https://github.com/JacobEvelyn/friends/issues/183)

**Merged pull requests:**

- Add ability to add new friends and locations from events [\#190](https://github.com/JacobEvelyn/friends/pull/190) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Add advanced search \(grep\) examples to README [\#188](https://github.com/JacobEvelyn/friends/pull/188) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.35](https://github.com/JacobEvelyn/friends/tree/v0.35) (2018-01-14)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.34...v0.35)

**Implemented enhancements:**

- Add notes [\#175](https://github.com/JacobEvelyn/friends/issues/175)

**Merged pull requests:**

- Add ability to add notes [\#187](https://github.com/JacobEvelyn/friends/pull/187) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.34](https://github.com/JacobEvelyn/friends/tree/v0.34) (2018-01-10)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.33...v0.34)

**Implemented enhancements:**

- Newer activities should always appear above older activities on the same date [\#184](https://github.com/JacobEvelyn/friends/issues/184)

**Merged pull requests:**

- Always sort activities stably within a date [\#185](https://github.com/JacobEvelyn/friends/pull/185) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.33](https://github.com/JacobEvelyn/friends/tree/v0.33) (2017-08-22)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.32...v0.33)

**Implemented enhancements:**

- Prevent dates without years from being in the future [\#181](https://github.com/JacobEvelyn/friends/pull/181) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.32](https://github.com/JacobEvelyn/friends/tree/v0.32) (2017-07-25)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.31...v0.32)

**Fixed bugs:**

- Incorrect version of `gli` specified in gemspec [\#178](https://github.com/JacobEvelyn/friends/issues/178)

**Merged pull requests:**

- Fix gli dependency [\#179](https://github.com/JacobEvelyn/friends/pull/179) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.31](https://github.com/JacobEvelyn/friends/tree/v0.31) (2017-06-02)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.30...v0.31)

**Implemented enhancements:**

- Change graph commands to display filtered graphs within total [\#171](https://github.com/JacobEvelyn/friends/issues/171)

**Fixed bugs:**

- Graph does not display more than 42 activities per month [\#172](https://github.com/JacobEvelyn/friends/issues/172)

**Closed issues:**

- Reduce dependencies [\#167](https://github.com/JacobEvelyn/friends/issues/167)
- Add standalone distribution [\#160](https://github.com/JacobEvelyn/friends/issues/160)
- Integrate with cron for regular reminders [\#56](https://github.com/JacobEvelyn/friends/issues/56)

**Merged pull requests:**

- Improve graph command [\#174](https://github.com/JacobEvelyn/friends/pull/174) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Remove Memoist dependency and bump gem dependencies [\#170](https://github.com/JacobEvelyn/friends/pull/170) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Remove warnings when running tests [\#169](https://github.com/JacobEvelyn/friends/pull/169) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.30](https://github.com/JacobEvelyn/friends/tree/v0.30) (2017-05-30)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.29...v0.30)

**Implemented enhancements:**

- Code coverage in README is too low [\#163](https://github.com/JacobEvelyn/friends/issues/163)
- Improve display of favorites for ties [\#158](https://github.com/JacobEvelyn/friends/issues/158)
- Filter activities based on more than one friend/tag/etc. [\#88](https://github.com/JacobEvelyn/friends/issues/88)

**Closed issues:**

- Reduce warnings [\#166](https://github.com/JacobEvelyn/friends/issues/166)

**Merged pull requests:**

- Be able to filter output by more than one friend or tag [\#168](https://github.com/JacobEvelyn/friends/pull/168) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Improve display of favorites for ties [\#165](https://github.com/JacobEvelyn/friends/pull/165) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Correct code coverage calculations [\#164](https://github.com/JacobEvelyn/friends/pull/164) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.29](https://github.com/JacobEvelyn/friends/tree/v0.29) (2017-03-18)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.28...v0.29)

**Implemented enhancements:**

- Add `--since \<date\>` and `--until \<date\>` flags, and remove extraneous months from `graph` [\#153](https://github.com/JacobEvelyn/friends/issues/153)
- Add integration tests for bin/friends? [\#127](https://github.com/JacobEvelyn/friends/issues/127)

**Merged pull requests:**

- Add --since and --until flags to `graph` and `list activities` [\#157](https://github.com/JacobEvelyn/friends/pull/157) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Restructuring [\#155](https://github.com/JacobEvelyn/friends/pull/155) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.28](https://github.com/JacobEvelyn/friends/tree/v0.28) (2016-06-25)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.27...v0.28)

**Implemented enhancements:**

- Output `list friends` in color [\#125](https://github.com/JacobEvelyn/friends/issues/125)

**Merged pull requests:**

- Colorize `list friends` and add --colorless flag [\#151](https://github.com/JacobEvelyn/friends/pull/151) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.27](https://github.com/JacobEvelyn/friends/tree/v0.27) (2016-06-22)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.26...v0.27)

**Implemented enhancements:**

- Allow tags to be added and removed from friends without quotes [\#148](https://github.com/JacobEvelyn/friends/issues/148)
- Allow multi-word locations to be added without quotes [\#147](https://github.com/JacobEvelyn/friends/issues/147)
- Speed up initialization [\#143](https://github.com/JacobEvelyn/friends/issues/143)
- `friends update` can skip reading the friends.md file [\#137](https://github.com/JacobEvelyn/friends/issues/137)
- Add Gemnasium badge to README [\#130](https://github.com/JacobEvelyn/friends/issues/130)

**Fixed bugs:**

- Commands that find a friend fail on exact text matches when there's more than one fuzzy match [\#149](https://github.com/JacobEvelyn/friends/issues/149)

**Merged pull requests:**

- Small improvements to UX for some commands [\#150](https://github.com/JacobEvelyn/friends/pull/150) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Bump development dependencies [\#146](https://github.com/JacobEvelyn/friends/pull/146) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Skips reading the `friends.md` file on update [\#145](https://github.com/JacobEvelyn/friends/pull/145) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Simplify code and improve performance [\#144](https://github.com/JacobEvelyn/friends/pull/144) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Add Gemnasium integration with README badge [\#142](https://github.com/JacobEvelyn/friends/pull/142) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.26](https://github.com/JacobEvelyn/friends/tree/v0.26) (2016-05-23)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.25...v0.26)

**Fixed bugs:**

- Adding/filtering friend with tag but no nickname incorrectly counts the tag as part of the name [\#140](https://github.com/JacobEvelyn/friends/issues/140)
- Error: stack level too deep [\#136](https://github.com/JacobEvelyn/friends/issues/136)

**Merged pull requests:**

- Fix deserialization for friends with tags and no nicknames [\#141](https://github.com/JacobEvelyn/friends/pull/141) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.25](https://github.com/JacobEvelyn/friends/tree/v0.25) (2016-05-22)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.24...v0.25)

**Closed issues:**

- Remove tag-migration code for 1.0 release [\#139](https://github.com/JacobEvelyn/friends/issues/139)

**Merged pull requests:**

- Make tag-migration code simpler [\#138](https://github.com/JacobEvelyn/friends/pull/138) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Add rubocop run to TravisCI [\#135](https://github.com/JacobEvelyn/friends/pull/135) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.24](https://github.com/JacobEvelyn/friends/tree/v0.24) (2016-05-17)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.23...v0.24)

**Implemented enhancements:**

- Change \#hashtags to @tags [\#122](https://github.com/JacobEvelyn/friends/issues/122)

**Fixed bugs:**

- Uninitialized constant Friends::Activity::Set when graphing by tag [\#133](https://github.com/JacobEvelyn/friends/issues/133)

**Merged pull requests:**

- Change tags to `@tag` format, auto-migrate old tags, and fix set loading issue [\#134](https://github.com/JacobEvelyn/friends/pull/134) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.23](https://github.com/JacobEvelyn/friends/tree/v0.23) (2016-05-16)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.22...v0.23)

**Implemented enhancements:**

- Change `graph` to use `--with`, `--tagged`, and `--in` flags [\#124](https://github.com/JacobEvelyn/friends/issues/124)
- Add `graph` command for locations [\#109](https://github.com/JacobEvelyn/friends/issues/109)

**Merged pull requests:**

- Allow graph to be filtered by friend, location and hashtag [\#129](https://github.com/JacobEvelyn/friends/pull/129) ([andypearson](https://github.com/andypearson))

## [v0.22](https://github.com/JacobEvelyn/friends/tree/v0.22) (2016-05-14)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.21...v0.22)

**Fixed bugs:**

- Fix `undefined variable "limit"` errors [\#128](https://github.com/JacobEvelyn/friends/issues/128)

## [v0.21](https://github.com/JacobEvelyn/friends/tree/v0.21) (2016-05-14)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.20...v0.21)

**Implemented enhancements:**

- Remove need for quotes from `friends add activity` [\#121](https://github.com/JacobEvelyn/friends/issues/121)
- Remove need for quotes from `friends add friend` [\#120](https://github.com/JacobEvelyn/friends/issues/120)

**Merged pull requests:**

- Fix favorite commands \(undefined variable "limit"\) [\#126](https://github.com/JacobEvelyn/friends/pull/126) ([andypearson](https://github.com/andypearson))
- Remove need to quote for `add friend` and `add activity` [\#123](https://github.com/JacobEvelyn/friends/pull/123) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.20](https://github.com/JacobEvelyn/friends/tree/v0.20) (2016-05-08)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.19...v0.20)

**Implemented enhancements:**

- Add --tagged option to `list friends` [\#119](https://github.com/JacobEvelyn/friends/issues/119)
- Add --verbose option to `list friends` [\#117](https://github.com/JacobEvelyn/friends/issues/117)
- Add `list hashtags` command [\#116](https://github.com/JacobEvelyn/friends/issues/116)
- Add hashtag capabilities to friends [\#90](https://github.com/JacobEvelyn/friends/issues/90)
- Add hashtag capabilities to activities [\#89](https://github.com/JacobEvelyn/friends/issues/89)
- Add location data to friends [\#66](https://github.com/JacobEvelyn/friends/issues/66)

**Merged pull requests:**

- Implement hashtags [\#118](https://github.com/JacobEvelyn/friends/pull/118) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.19](https://github.com/JacobEvelyn/friends/tree/v0.19) (2016-05-02)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.18...v0.19)

**Implemented enhancements:**

- Add command to list favorite locations [\#108](https://github.com/JacobEvelyn/friends/issues/108)

**Merged pull requests:**

- Add `list favorite locations` command [\#115](https://github.com/JacobEvelyn/friends/pull/115) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.18](https://github.com/JacobEvelyn/friends/tree/v0.18) (2016-05-02)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.17...v0.18)

**Implemented enhancements:**

- Improve documentation [\#92](https://github.com/JacobEvelyn/friends/issues/92)
- Have a way to correct mistakes? [\#91](https://github.com/JacobEvelyn/friends/issues/91)
- Allow friends to be found with first name and last name initial [\#87](https://github.com/JacobEvelyn/friends/issues/87)

**Fixed bugs:**

- Nicknames including first names should match over first name [\#111](https://github.com/JacobEvelyn/friends/issues/111)

**Merged pull requests:**

- Match friends with first name and last name initial [\#114](https://github.com/JacobEvelyn/friends/pull/114) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Give nicknames matching precedence over first names [\#113](https://github.com/JacobEvelyn/friends/pull/113) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Add `friends edit` command [\#112](https://github.com/JacobEvelyn/friends/pull/112) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Organize documentation in README [\#110](https://github.com/JacobEvelyn/friends/pull/110) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.17](https://github.com/JacobEvelyn/friends/tree/v0.17) (2016-03-28)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.16...v0.17)

**Implemented enhancements:**

- Add --in flag to `suggest` [\#106](https://github.com/JacobEvelyn/friends/issues/106)
- Allow locations to be renamed [\#105](https://github.com/JacobEvelyn/friends/issues/105)
- Add --in location flag to `list activities` [\#100](https://github.com/JacobEvelyn/friends/issues/100)
- Add --in location flag to `list friends` [\#99](https://github.com/JacobEvelyn/friends/issues/99)
- Add location matching to activity descriptions [\#97](https://github.com/JacobEvelyn/friends/issues/97)
- Add `list locations` command [\#96](https://github.com/JacobEvelyn/friends/issues/96)
- Add `add location` command [\#95](https://github.com/JacobEvelyn/friends/issues/95)
- Add backwards-compatible \#\#\# Locations: heading to friends.md file. [\#94](https://github.com/JacobEvelyn/friends/issues/94)
- Update documentation for `graph` and `stats` commands [\#93](https://github.com/JacobEvelyn/friends/issues/93)
- Add location features [\#107](https://github.com/JacobEvelyn/friends/pull/107) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Fix documentation formatting and typos [\#104](https://github.com/JacobEvelyn/friends/pull/104) ([andypearson](https://github.com/andypearson))
- Add backwards-compatible `add location` and `list locations` commands [\#101](https://github.com/JacobEvelyn/friends/pull/101) ([JacobEvelyn](https://github.com/JacobEvelyn))

**Merged pull requests:**

- Add location matching/highlighting to activities [\#103](https://github.com/JacobEvelyn/friends/pull/103) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Add documentation for `graph` and `stats` commands [\#102](https://github.com/JacobEvelyn/friends/pull/102) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.16](https://github.com/JacobEvelyn/friends/tree/v0.16) (2016-03-23)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.15...v0.16)

**Implemented enhancements:**

- Allow `graph` without arguments to graph all activities [\#83](https://github.com/JacobEvelyn/friends/issues/83)

**Merged pull requests:**

- Allow `graph` without arguments to graph all activities \(Closes \#83\) [\#85](https://github.com/JacobEvelyn/friends/pull/85) ([andypearson](https://github.com/andypearson))

## [v0.15](https://github.com/JacobEvelyn/friends/tree/v0.15) (2016-03-11)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.14...v0.15)

## [v0.14](https://github.com/JacobEvelyn/friends/tree/v0.14) (2016-03-11)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.13...v0.14)

**Implemented enhancements:**

- Allow dates in natural-language formats [\#65](https://github.com/JacobEvelyn/friends/issues/65)

**Merged pull requests:**

- Allow natural-language dates [\#82](https://github.com/JacobEvelyn/friends/pull/82) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.13](https://github.com/JacobEvelyn/friends/tree/v0.13) (2016-01-21)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.12...v0.13)

**Fixed bugs:**

- Treat double names as a single name [\#80](https://github.com/JacobEvelyn/friends/issues/80)

**Closed issues:**

- 4 RuboCop errors prevent git commit [\#78](https://github.com/JacobEvelyn/friends/issues/78)

**Merged pull requests:**

- Improve handling of double-names and names within names [\#81](https://github.com/JacobEvelyn/friends/pull/81) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Update RuboCop and fix many offenses [\#79](https://github.com/JacobEvelyn/friends/pull/79) ([codyjroberts](https://github.com/codyjroberts))

## [v0.12](https://github.com/JacobEvelyn/friends/tree/v0.12) (2016-01-16)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.11...v0.12)

**Implemented enhancements:**

- Add examples for rename command in README [\#76](https://github.com/JacobEvelyn/friends/issues/76)
- Add change name command [\#68](https://github.com/JacobEvelyn/friends/issues/68)

**Merged pull requests:**

- Update README and CONTRIBUTING docs. Closes \#76 [\#77](https://github.com/JacobEvelyn/friends/pull/77) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Add rename friend [\#75](https://github.com/JacobEvelyn/friends/pull/75) ([codyjroberts](https://github.com/codyjroberts))

## [v0.11](https://github.com/JacobEvelyn/friends/tree/v0.11) (2016-01-13)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.10...v0.11)

**Fixed bugs:**

- friends update doesn't correctly compare version numbers [\#72](https://github.com/JacobEvelyn/friends/issues/72)
- Date gets duplicated with each new activity [\#71](https://github.com/JacobEvelyn/friends/issues/71)

**Merged pull requests:**

- Fix bug in comparing gem versions for update [\#74](https://github.com/JacobEvelyn/friends/pull/74) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Fix bug in how dates are deserialized [\#73](https://github.com/JacobEvelyn/friends/pull/73) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.10](https://github.com/JacobEvelyn/friends/tree/v0.10) (2016-01-12)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.9...v0.10)

**Implemented enhancements:**

- Add --debug flag for error backtraces [\#62](https://github.com/JacobEvelyn/friends/issues/62)

**Fixed bugs:**

- The same name is only highlighted once per description [\#35](https://github.com/JacobEvelyn/friends/issues/35)

**Closed issues:**

- Don't write files in middle of commands [\#60](https://github.com/JacobEvelyn/friends/issues/60)
- Remove require\_relative from codebase [\#58](https://github.com/JacobEvelyn/friends/issues/58)
- Cleanly separate Introvert from non-library concerns [\#57](https://github.com/JacobEvelyn/friends/issues/57)

**Merged pull requests:**

- Highlight multiple occurrences [\#70](https://github.com/JacobEvelyn/friends/pull/70) ([GuruKhalsa](https://github.com/GuruKhalsa))
- Fix Travis badge \(master only\) [\#67](https://github.com/JacobEvelyn/friends/pull/67) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Move activity prompt to bin/friends [\#64](https://github.com/JacobEvelyn/friends/pull/64) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Adds the --debug flag for printing backtraces on error [\#63](https://github.com/JacobEvelyn/friends/pull/63) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Move file writes to end of command actions [\#61](https://github.com/JacobEvelyn/friends/pull/61) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Remove require\_relative from codebase [\#59](https://github.com/JacobEvelyn/friends/pull/59) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.9](https://github.com/JacobEvelyn/friends/tree/v0.9) (2016-01-07)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.8...v0.9)

**Implemented enhancements:**

- Add command to retrieve basic stats [\#36](https://github.com/JacobEvelyn/friends/issues/36)

**Merged pull requests:**

- Add stats command [\#55](https://github.com/JacobEvelyn/friends/pull/55) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.8](https://github.com/JacobEvelyn/friends/tree/v0.8) (2016-01-06)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.7...v0.8)

**Implemented enhancements:**

- Reference friends by real name or nickname [\#40](https://github.com/JacobEvelyn/friends/issues/40)

**Merged pull requests:**

- Fix nicknames bug and add README documentation [\#54](https://github.com/JacobEvelyn/friends/pull/54) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Add basic nickname support [\#53](https://github.com/JacobEvelyn/friends/pull/53) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Add CHANGELOG.md and RELEASING.md [\#52](https://github.com/JacobEvelyn/friends/pull/52) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Update Code of Conduct [\#51](https://github.com/JacobEvelyn/friends/pull/51) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Improve contributing documentation [\#50](https://github.com/JacobEvelyn/friends/pull/50) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Add badgefury.io badge [\#49](https://github.com/JacobEvelyn/friends/pull/49) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.7](https://github.com/JacobEvelyn/friends/tree/v0.7) (2016-01-05)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.6...v0.7)

**Fixed bugs:**

- Error: undefined method `n\_activities' for nil:NilClass [\#44](https://github.com/JacobEvelyn/friends/issues/44)
- Documentation link doesn't work [\#43](https://github.com/JacobEvelyn/friends/issues/43)

**Merged pull requests:**

- Fix `suggest` command for low number of friends [\#48](https://github.com/JacobEvelyn/friends/pull/48) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Update README URLs based on HTTP redirects [\#46](https://github.com/JacobEvelyn/friends/pull/46) ([ReadmeCritic](https://github.com/ReadmeCritic))

## [v0.6](https://github.com/JacobEvelyn/friends/tree/v0.6) (2016-01-03)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.5...v0.6)

**Merged pull requests:**

- Test versions [\#41](https://github.com/JacobEvelyn/friends/pull/41) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.5](https://github.com/JacobEvelyn/friends/tree/v0.5) (2016-01-03)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.4...v0.5)

**Fixed bugs:**

- Activities added on the same day have their order reversed [\#37](https://github.com/JacobEvelyn/friends/issues/37)

**Merged pull requests:**

- Make activities on same day chronologically ordered [\#38](https://github.com/JacobEvelyn/friends/pull/38) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.4](https://github.com/JacobEvelyn/friends/tree/v0.4) (2015-11-14)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.3...v0.4)

## [v0.3](https://github.com/JacobEvelyn/friends/tree/v0.3) (2015-11-11)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.2...v0.3)

**Implemented enhancements:**

- Be able to enter activity with normal prompt [\#34](https://github.com/JacobEvelyn/friends/issues/34)
- Create file if none exists [\#25](https://github.com/JacobEvelyn/friends/issues/25)
- Friends should be able to have nicknames [\#17](https://github.com/JacobEvelyn/friends/issues/17)
- Add ability to change friend name [\#16](https://github.com/JacobEvelyn/friends/issues/16)
- Auto-update? [\#8](https://github.com/JacobEvelyn/friends/issues/8)

## [v0.2](https://github.com/JacobEvelyn/friends/tree/v0.2) (2015-11-08)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.1...v0.2)

## [v0.1](https://github.com/JacobEvelyn/friends/tree/v0.1) (2015-11-03)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.0.6...v0.1)

## [v0.0.6](https://github.com/JacobEvelyn/friends/tree/v0.0.6) (2015-06-28)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.0.5...v0.0.6)

**Implemented enhancements:**

- Have robustness around name extraction from activities [\#21](https://github.com/JacobEvelyn/friends/issues/21)

## [v0.0.5](https://github.com/JacobEvelyn/friends/tree/v0.0.5) (2015-06-28)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.0.4...v0.0.5)

## [v0.0.4](https://github.com/JacobEvelyn/friends/tree/v0.0.4) (2015-06-01)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.0.3...v0.0.4)

**Merged pull requests:**

- Bump version to 0.0.3 [\#33](https://github.com/JacobEvelyn/friends/pull/33) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.0.3](https://github.com/JacobEvelyn/friends/tree/v0.0.3) (2015-05-28)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.0.2...v0.0.3)

**Merged pull requests:**

- Allow limiting of activity lists [\#32](https://github.com/JacobEvelyn/friends/pull/32) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Improve friend matching code [\#31](https://github.com/JacobEvelyn/friends/pull/31) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.0.2](https://github.com/JacobEvelyn/friends/tree/v0.0.2) (2015-01-11)
[Full Changelog](https://github.com/JacobEvelyn/friends/compare/v0.0.1...v0.0.2)

**Implemented enhancements:**

- Add confirmation after commands \(and --quiet\) [\#28](https://github.com/JacobEvelyn/friends/issues/28)
- Have activity dates default to today if none provided [\#27](https://github.com/JacobEvelyn/friends/issues/27)
- Add more detailed usage example to README. [\#23](https://github.com/JacobEvelyn/friends/issues/23)
- Put activities before friends in friends.md [\#20](https://github.com/JacobEvelyn/friends/issues/20)
- Friend name lookups should be case-insensitive [\#18](https://github.com/JacobEvelyn/friends/issues/18)
- Add link to RubyDoc in README [\#12](https://github.com/JacobEvelyn/friends/issues/12)
- Release to RubyGems [\#10](https://github.com/JacobEvelyn/friends/issues/10)
- Gracefully handle friend name conflicts in all commands [\#7](https://github.com/JacobEvelyn/friends/issues/7)
- Be able to list activities [\#6](https://github.com/JacobEvelyn/friends/issues/6)
- Be able to add activities [\#5](https://github.com/JacobEvelyn/friends/issues/5)
- Be able to add new friends [\#4](https://github.com/JacobEvelyn/friends/issues/4)
- Respect params for new file location [\#3](https://github.com/JacobEvelyn/friends/issues/3)
- Comment all classes and methods \(YARD\) [\#2](https://github.com/JacobEvelyn/friends/issues/2)
- Add more test coverage [\#1](https://github.com/JacobEvelyn/friends/issues/1)

**Merged pull requests:**

- Improve documentation [\#30](https://github.com/JacobEvelyn/friends/pull/30) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Add confirm messages and --quiet switch [\#29](https://github.com/JacobEvelyn/friends/pull/29) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Put activities above friends in file [\#26](https://github.com/JacobEvelyn/friends/pull/26) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Make friend matching case-insensitive. [\#24](https://github.com/JacobEvelyn/friends/pull/24) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Basic add-activity feature in place [\#22](https://github.com/JacobEvelyn/friends/pull/22) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Feature/list activities [\#19](https://github.com/JacobEvelyn/friends/pull/19) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Switch from Thor to GLI [\#15](https://github.com/JacobEvelyn/friends/pull/15) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Add more Introvert tests and command-line arg handling [\#14](https://github.com/JacobEvelyn/friends/pull/14) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Ignore gem files [\#13](https://github.com/JacobEvelyn/friends/pull/13) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Clean up gemspec dependencies [\#11](https://github.com/JacobEvelyn/friends/pull/11) ([JacobEvelyn](https://github.com/JacobEvelyn))
- Clean up README [\#9](https://github.com/JacobEvelyn/friends/pull/9) ([JacobEvelyn](https://github.com/JacobEvelyn))

## [v0.0.1](https://github.com/JacobEvelyn/friends/tree/v0.0.1) (2014-12-11)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
