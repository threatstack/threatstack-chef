Threat Stack Cookbook
================

[![Build Status](https://travis-ci.org/threatstack/threatstack-chef.svg?branch=master)][travis]
[![Cookbook Version](http://img.shields.io/cookbook/v/threatstack.svg)][cookbook]

[travis]: https://travis-ci.org/threatstack/threatstack-chef
[cookbook]: https://supermarket.chef.io/cookbooks/threatstack

** NOTE **: As of 2.x of this cookbook we only explicitly support chef 12.15 or greater.

Chef recipes to deploy the Threat Stack server agent

Requirements
============
- chef > 12.15

Platforms
---------

* Amazon Linux
* CentOS
* RedHat
* Ubuntu

Cookbooks
---------

The following Opscode cookbooks are dependencies:

* `apt`
* `yum`


Recipes
=======

default
-------
Installs the Threat Stack agent package and register the agent with the service

repo
--------
Sets up the Apt or Yum repo for installing the Threat Stack agent package

Usage
=====

1. Add this cookbook to your Chef Server or add to your Berksfile
  ```
  cookbook 'threatstack', '~> 1.0.0'
  ```

2. Add your deploy api key. The recommended way is to use an encrypted databag
with name and item specified by the corresponding attributes. The cookbook will
use the `'deploy_key'` value from the databag by default.
You can also set the key directly or using a wrapper cookbook in the `node['threatstack']['deploy_key']` attribute.
Setting the key will disable the encrypted data bag lookup.

Additionally you we can read the deploy key from the `node.run_state['threatstack']['deploy_key']` location
Simply set the value of the deploy key in the run state at that location.

3. Set the `node['threatstack']['feature_plan']` appropriately for your organzation

4. Add this recipe to your runlist or include in another recipe

Attributes
==========

`node['threatstack']['version']` - Set to pin to a specific Threat Stack agent release version.

`node['threatstack']['pkg_action']` - Set to `:upgrade` if you want to take the latest release (defaults to `:install`).

`node['threatstack']['pkg_opts']` - Override this if you want to send custom package options to the package resource (defaults to `nil`).

`node['threatstack']['deploy_key']` - Override this with your deploy key for agent registration.

`node['threatstack']['feature_plan']` - Threat Stack feature plan. (values: monitor, investigate, legacy; see: https://www.threatstack.com/plans)

`node['threatstack']['data_bag_name']` - Name of the encrypted databag containing Threat Stack secrets

`node['threatstack']['data_bag_item']` - Name of the encrypted databag item containing Threat Stack secrets.

`node['threatstack']['rulesets']` - Set or override this with an array of rulesets to apply to the node.

`node['threatstack']['hostname']` - register the agent in the UI by a specific name (defaults to hostname).

`node['threatstack']['agent_config_args']` - array of arguments to enable platform features via `cloudsight config`.

`node['threatstack']['cloudsight_service_timer']` - a [Chef timer](https://docs.chef.io/resource_common.html#resource-common-notifications) to manage the agent service with.

Encrypted Data Bag Contents
===========================
`deploy_key` - the deploy key for agent registration.
