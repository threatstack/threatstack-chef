#
# Cookbook Name:: threatstack
# Recipe:: default
#
# Copyright 2014-2019, Threat Stack
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
#
# == This recipe will install the tsagent and start the service.
# == It supports agent versions >= 2.0. For previous versions of
# == the agent, refer to older versions of this cookbook, tagged
# == in the git repo.

unless node['threatstack']['version'].nil?
  if node['threatstack']['version'].start_with?('1.')
    error_string = "Deprecation Error: Unsupported agent version detected ( #{node['threatstack']['version']} ).\n"
    error_string += 'For agent versions < 2.0, use a previous version of this cookbook.'
    raise NotImplementedError, error_string
  end
end

service 'threatstack' do
  supports status: true, restart: true, start: true, stop: true
end

if node['threatstack']['repo_enable']
  if platform_family?('fedora', 'amazon')
    include_recipe 'threatstack::rhel'
  else
    include_recipe "threatstack::#{node['platform_family']}"
  end
end

# Disable auditd on amazon linux
execute 'stop_auditd' do # ~FC004 This is a workaround for auditd not stoppable with the standard method
  command 'service auditd stop'
  only_if { platform_family?('amazon') }
end

execute 'disable_auditd' do
  command 'systemctl disable auditd'
  only_if { platform_family?('amazon') }
end

package 'threatstack-agent' do
  version node['threatstack']['version'] if node['threatstack']['version']
  if node['threatstack']['version'].nil?
    action :upgrade
  else
    action :install
  end
  notifies :run, 'execute[stop_auditd]', :before
  notifies :run, 'execute[disable_auditd]', :before
end

if node.run_state.key?('threatstack')
  if node.run_state['threatstack'].key?('deploy_key')
    deploy_key = node.run_state['threatstack']['deploy_key']
  end
elsif node['threatstack']['deploy_key']
  deploy_key = node['threatstack']['deploy_key']
else
  deploy_key = data_bag_item(
    node['threatstack']['data_bag_name'],
    node['threatstack']['data_bag_item']
  )['deploy_key']
end

if deploy_key.nil? || deploy_key.empty?
  raise 'No Threat Stack deploy key found in run state, attributes, or data bag. Cannot continue.'
end

# Register the Threat Stack agent - Rulesets are not required
# and if it's omitted then the agent will be placed into a
# default rule set (most likely 'Base Rule Set')
cmd = ''
cmd += "tsagent setup --deploy-key=#{deploy_key}"
cmd += " --hostname='#{node['threatstack']['hostname']}'" if node['threatstack']['hostname']
cmd += " --url='#{node['threatstack']['url']}'" if node['threatstack']['url']

# Handle rulesets here, multiple rulesets are supported.
unless node['threatstack']['rulesets'].empty?
  rulesets_string = node['threatstack']['rulesets'].join(',')
  cmd += " --ruleset='#{rulesets_string}'"
end

#### Setup happens here ####
execute 'tsagent setup' do
  command cmd
  action :run
  retries 3
  timeout 60
  ignore_failure node['threatstack']['ignore_failure']
  sensitive true
  not_if do
    ::File.exist?('/opt/threatstack/etc/tsagentd.cfg')
  end
  # default to delayed start in case config is needed.
  notifies :start, 'service[threatstack]'
end

#### Config-specific work below ####
# tsagent configuration settings/flags
# We need to create a duplicate of the node attribute
# since we may change the variable's value later.
agent_config_args = node['threatstack']['agent_config_args'].dup

# By default, container observation is off; this setting will
# turn it on.
unless node['threatstack']['enable_containers'].nil?
  agent_config_args.push('enable_containers 1')
end

# Additional configuration options are set here.
config_command = ''
unless agent_config_args.empty?
  agent_config_args.each do |arg|
    config_command += "tsagent config --set #{arg}; "
  end
end

# Store config statements in a file, which will help us understand
# if they have changed since previous chef runs, and determine if we should
# restart the agent so new config goes into effect.
file '/opt/threatstack/etc/chef_args_cache.txt' do
  content config_command
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  not_if { config_command == '' }
  notifies :run, 'execute[tsagent config]', :immediately
end

# Config must be run prior to starting the agent. If config is run after the agent is
# started, then the agent must be restarted.
execute 'tsagent config' do
  command config_command
  retries 3
  timeout 10
  action :nothing
  notifies :restart, 'service[threatstack]'
end
