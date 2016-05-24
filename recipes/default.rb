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
cmd += " #{node['threatstack']['agent_extra_args']}" if node['threatstack']['agent_extra_args'] != ''

# Handle ruleset management via here.
if ! node['threatstack']['rulesets'].empty?
  node['threatstack']['rulesets'].each do |r|
    cmd += " --ruleset='#{r}'"

    # This file is maintained because the list of rulesets is not readily accessible
    # in a ThreatStack agent install, and we want to re-run the registration
    # process when the ruleset list changes.
    file '/opt/threatstack/etc/active_rulesets.txt' do
      content node['threatstack']['rulesets'].join("\n").concat("\n")
      mode 0644
      owner 'root'
      group 'root'
    end

    # deleting this file allows cloudsight to be reconfigured after installation
    file '/opt/threatstack/cloudsight/config/.secret' do
      action :nothing
      subscribes :delete, 'file[/opt/threatstack/etc/active_rulesets.txt]', :immediately
    end

    # Only if we are about to reconfigure a running instance
    execute 'stop threatstack services' do
      command 'service cloudsight stop'
      action :nothing
      subscribes :run, 'file[/opt/threatstack/etc/active_rulesets.txt]', :immediately
    end
  end
end

if node['threatstack']['configure_agent']
  execute 'cloudsight setup' do
    command cmd
    action :run
    retries 3
    timeout 60
    ignore_failure node['threatstack']['ignore_failure']
    if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('11.14.0')
      sensitive true
    end
    not_if do
      ::File.exist?('/opt/threatstack/cloudsight/config/.audit') &&
        ::File.exist?('/opt/threatstack/cloudsight/config/.secret')
    end
  end
  if node['threatstack']['agent_config_args']
    file '/opt/threatstack/cloudsight/config/.config_args' do
      owner 'root'
      group 'root'
      mode 0644
      content node['threatstack']['agent_config_args']
      notifies :run, 'execute[cloudsight configure]'
    end

    execute 'cloudsight configure' do
      command "cloudsight config #{node['threatstack']['agent_config_args']}"
      action :nothing
      retries 3
      timeout 60
      if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('11.14.0')
        sensitive true
      end
      notifies :restart, 'service[cloudsight]'
    end
  end
end

service 'cloudsight' do
  action :enable
  supports restart: true
end
