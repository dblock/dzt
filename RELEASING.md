# Releasing Dzt

There're no particular rules about when to release dzt. Release bug fixes frequenty, features not so frequently and breaking API changes rarely.

### Release

Run tests, check that all tests succeed locally.

```
bundle install
rake
```

Check that the last build succeeded in [Travis CI](https://travis-ci.org/tim-vandecasteele/dzt) for all supported platforms.

Increment the version, modify [lib/dzt/version.rb](lib/dzt/version.rb).

*  Increment the third number if the release has bug fixes and/or very minor features, only (eg. change `0.7.1` to `0.2.0`).
*  Increment the second number if the release contains major features or breaking API changes (eg. change `0.7.1` to `0.8.0`).

Change "Next Release" in [CHANGELOG.md](CHANGELOG.md) to the new version.

```
### 0.2.0 (14/10/2014)
```

Remove the line with "Your contribution here.", since there will be no more contributions to this release.

Commit your changes.

```
git add CHANGELOG.md lib/dzt/version.rb
git commit -m "Preparing for release, 0.2.0."
git push origin master
```

Release.

```
$ rake release

dzt 0.2.0 built to pkg/dzt-0.2.0.gem.
Tagged v0.2.0.
Pushed git commits and tags.
Pushed dzt 0.2.0 to rubygems.org.
```

### Prepare for the Next Version

Add the next release to [CHANGELOG.md](CHANGELOG.md).

```
Next Release
============

* Your contribution here.
```

Comit your changes.

```
git add CHANGELOG.md
git commit -m "Preparing for next release."
git push origin master
```
