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
To run all unit and linting tests:
```
bundle exec rake
```

### Integration Tests

This tests a number of different integration test suites using docker containers. They are
setup to run under test-kitchen:

Requirements:
To run integration testing you need a valid threatstack agent deployment key
Get your deployment key from the Threat Stack application under "Settings" -> "Applications Keys"

**Example:**
```
export TS_DEPLOY_KEY=<deploy key>
export TS_CONFIG_ARGS=['fim.log yes']
```

Local container integration testing
---------------
Container (with docker) testing through the Kitchen-CI toolset can be done locally. You must have
docker installed. The `.kitchen.yml` file drives the configuration and execution of the tests.

To run tests, use the kitchen framework. The following will run all tests:
```
bundle exec kitchen test
```
