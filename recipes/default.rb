#
# Cookbook Name:: threatstack
# Recipe:: repo
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

include_recipe 'threatstack::repo'

package 'threatstack-agent' do
  version node['threatstack']['version'] if node['threatstack']['version']
  action node['threatstack']['pkg_action']
end

# Register the Threat Stack agent - Policy is not required
# and if it's omitted then the agent will need to be approved
# in the Threat Stack UI

cmd = "cloudsight setup --deploy-key=#{node['threatstack']['deploy_key']}"
cmd += " --hostname='#{node['threatstack']['hostname']}'" if node['threatstack']['hostname']

node['threatstack']['rulesets'].each do |r|
  cmd += " --ruleset='#{r}'"
end

execute 'cloudsight setup' do
  command cmd
  action :run
  not_if { ::File.exist?('/opt/threatstack/cloudsight/config/.secret') }
end
