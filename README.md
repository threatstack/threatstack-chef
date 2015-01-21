Threat Stack Cookbook
================

[![Build Status](https://travis-ci.org/threatstack/threatstack-chef.svg?branch=master)](https://travis-ci.org/threatstack/threatstack-chef)

Chef recipes to deploy the Threat Stack server agent

Requirements
============
- chef >= 10.14

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

2. Add your deploy api key to the `node['threatstack']['deploy_key']` attribute at a higher precedence level. Using either a wrapper cookbook or role or databag

3. (Optional) Set the `node['threatstack']['policy']` to define which policy will apply to this node (defaults to 'Default Policy')

4. Add this recipe to your runlist or include in another recipe
