#
# Cookbook Name:: threatstack
# Attributes:: default
#
# Copyright 2014-2015, Threat Stack
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['threatstack']['version'] = nil
default['threatstack']['pkg_action'] = :install
# If you want to send custom package options to the package resource
# use the attribute below
default['threatstack']['pkg_opts'] = nil
# If no rulesets are specified the agent will register to the default
# rule set, according to a comment in recipes/default.rb
default['threatstack']['rulesets'] = []
default['threatstack']['hostname'] = nil
default['threatstack']['ignore_failure'] = true

# You can set the deploy key directly, or use the encrypted databag
# parameters below. The value searched for will be 'deploy_key'
default['threatstack']['deploy_key'] = nil
default['threatstack']['data_bag_name'] = 'threatstack'
default['threatstack']['data_bag_item'] = 'api_keys'

# Threat Stack feature plan.  Valid string values:
# * investigate: Investigate package
# * monitor: Monitor package
# * legacy: Legacy Basic, Pro, Advanced packages
#
# See: https://www.threatstack.com/plans
default['threatstack']['feature_plan'] = nil

# Control the configuration of the Threat Stack agent.  Useful when installing
# agent into images.
default['threatstack']['configure_agent'] = true
# Pass aditional arguments to the agent during setup
default['threatstack']['agent_extra_args'] = ''
default['threatstack']['agent_config_args'] = []

# if configure_agent=false then we remove start in the cookbook
default['threatstack']['cloudsight_service_action'] = %i[enable start]

# Determines whether to start/restart the agent during or at the end of a
# converge. Should be a valid Chef timer.
default['threatstack']['cloudsight_service_timer'] = 'immediately'
