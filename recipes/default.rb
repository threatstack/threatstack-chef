#
# Cookbook Name:: threatstack
# Recipe:: default
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

include_recipe "threatstack::#{node['platform_family']}" if node['threatstack']['repo_enable']

package 'threatstack-agent' do
  version node['threatstack']['version'] if node['threatstack']['version']
  action node['threatstack']['pkg_action']
end

if node['threatstack']['deploy_key'].nil?
  deploy_key = Chef::EncryptedDataBagItem.load(
    node['threatstack']['data_bag_name'],
    node['threatstack']['data_bag_item']
  )['deploy_key']
else
  deploy_key = node['threatstack']['deploy_key']
end

# Register the Threat Stack agent - Rulesets are not required
# and if it's omitted then the agent will be placed into a
# default rule set (most like 'Base Rule Set')

cmd = "cloudsight setup --deploy-key=#{deploy_key}"
cmd += " --hostname='#{node['threatstack']['hostname']}'" if node['threatstack']['hostname']

node['threatstack']['rulesets'].each do |r|
  cmd += " --ruleset='#{r}'"
end

execute 'cloudsight setup' do
  command cmd
  action :run
  ignore_failure node['threatstack']['ignore_failure']
  sensitive true
  not_if { ::File.exist?('/opt/threatstack/cloudsight/config/.audit') }
end
