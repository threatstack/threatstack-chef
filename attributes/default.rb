#
# Cookbook:: threatstack
# Attributes:: default
#
# Copyright:: 2014-2020, Threat Stack
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
# If no rulesets are specified the agent will register to the default
# rule set, according to a comment in recipes/default.rb
default['threatstack']['rulesets'] = []
default['threatstack']['hostname'] = nil
default['threatstack']['ignore_failure'] = false

# You can set the deploy key directly, or use the encrypted databag
# parameters below. The value searched for will be 'deploy_key'
default['threatstack']['deploy_key'] = nil
default['threatstack']['data_bag_name'] = 'threatstack'
default['threatstack']['data_bag_item'] = 'api_keys'

# Control the configuration of the Threat Stack agent.  Useful when installing
# agent into images.
default['threatstack']['agent_config_args'] = []

# To enable host-based containers observation
default['threatstack']['enable_containers'] = nil

# To install the agent, but skip configuration for later, set this flag to true
# This can be useful in the case of baking an AMI for deployment later
default['threatstack']['install_only'] = false
