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

This tests a number of different suites, some of which require special credentials or virtual machine configurations.
Integration tests are setup to run under test-kitchen:

Requirements:
To run integration testing you need a valid threatstack agent deployment key
Get your deployment key from the Threat Stack application under "Settings" -> "Applications Keys"

```
export TS_DEPLOY_KEY=<deploy key>
export TS_CONFIG_ARGS=['fim.log yes']
```

Vagrant/local integration testing
---------------
Vagrant testing through the Kitchen-CI toolset can be done locally. You must have VirtualBox and vagrant installed.

To run tests, use the kitchen framework. The following will run all tests:
```
bundle exec kitchen test
```

Using ec2 nodes through vagrant
----------------------------------------
This approach to integration testing will allow you to use custom nodes, or cloud-specific nodes. (The most common case is Amazon Linux 1 and 2).

To test using ec2 instead of VirtualBox nodes, use the `.kitchen.ec2.yml` configuration file. You may need additional environment variables set for those tests (such as `AWS_SECRET_ACCESS_KEY`, `AWS_ACCESS_KEY_ID`, `AWS_SSH_KEY`, `SG_GROUP_IDS`, `SG_SUBNET_ID`, or `IMAGE_OWNER_ID`. 

You may not need all of those, but you likely need the AWS- ones for native kitchen-ec2 provisioning. 

To run tests on the EC2 kitchen file, run commands as follows: 
```
KITCHEN_YAML=".kitchen.ec2.yml" bundle exec kitchen test
```
