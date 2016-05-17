## Testing the cookbook

This cookbook has tests in the source repository. To run the tests:

```
git clone git://github.com/threatstack/threatstack-chef.git
cd threatstack-chef
bundle install
```

There are two kinds of tests in use: unit and integration tests.

### Unit Tests

The chef recipe is unit tested with chefspec, with additional linting with Foodcritic and Rubocop
To run spec tests only:

```
bundle exec rake spec
```

To run linting only:
```
bundle exec rake style
```
To run all tests:
```
bundle exec rake
```

### Integration Tests

Integration tests are setup to run under test-kitchen:

```
kitchen test
```

This tests a number of different suites, some of which require special credentials or virtual machine configurations. Please see the caveats and known issues below for additional details.
