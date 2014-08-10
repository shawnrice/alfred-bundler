Python Unit Tests
=================

The whole suite of Python unit tests can be run with the `test/python/run-tests.sh` script. It requires `nose`, `yanc` and `coverage`.

The aim is to maintain 100% code coverage (`run-tests.sh` will fail if coverage is not 100%), so there are many functional tests mixed in. These necessarily rely on other components of the Bundler, including the bash and PHP bundlers, GitHub and the icon server(s).

As the Bundler (and its tests) use components from the Web, it's a good idea to do your coding on a separate branch and push that to GitHub before running your tests. If the tests pass, merge the changes into `devel`.

To test a specific branch, set the `AB_BRANCH` environmental variable.
