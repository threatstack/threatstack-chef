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
#
# == Agent configuration and registration process
# Agent configuration and registration can be complicated and the code below
# can be difficult to understand.  This is a result of needing to solve for:
# * agent < 1.4.8 and agent >= 1.4.8 where we introduced a file with the
#   running configuration that can be checked.
# * initial configuration run v. subsequent configuration runs.
#   * initial runs will lack knowledge of the agent version being installed.
#     See first bullet why this matters.
#   * initial config run must be done before setup and MUST NOT restart the
#     agent service while subsequent runs, to reconfigure the agent, do not
#     invoke setup and MUST restart agent.
#
# We assume on first run that we don't know the agent version.  If
# node['threatstack']['agent_config_args'] is set then we precede
# `cloudsight setup` with `cloudsight config` commands IN
# execute[cloudsight setup].  WE DON'T EXECUTE 'execute[cloudsight configure]'
# ON THE INITIAL RUN TO CONFIGURE THE AGENT.
#
# On subsequent runs we are able to figure out the agent version.
# * If the agent version is < 1.4.8
#   * we drop a cookie file with the stringified
#     node['threatstack']['agent_config_args'] and notify
#     'execute[cloudsight configure]' of the resource change which will run
#     `cloudsight config` and notify 'service[cloudsight]' to restart.
# * If the agent version is >= 1.4.8
#   * we read config.json and check the values of
#     node['threatstack']['agent_config_args'] against the running
#     configuration.  On difference the 'execute[cloudsight configure]'
#     resource executes cloudsight config` and notifies
#     'service[cloudsight]' to restart.
#

if node['threatstack']['repo_enable']
  if platform_family?('fedora', 'amazon')
    include_recipe 'threatstack::rhel'
  else
    include_recipe "threatstack::#{node['platform_family']}"
  end
end

# Handle backwards compatibility from when we just passed a string to
# `cloudsight config`
if node['threatstack']['agent_config_args'].is_a? String
  agent_config_args = node['threatstack']['agent_config_args'].split(' ')
else
  agent_config_args = node['threatstack']['agent_config_args']
end

# Manage agent_plan arg from feature type.
case node['threatstack']['feature_plan']
when 'monitor'
  feature_plan_arg = 'agent_type="m"'
when 'investigate', 'legacy'
  feature_plan_arg = 'agent_type="i"'
else
  raise "The node['threatstack']['feature_plan'] attribute must be set to one of (monitor, investigate, or legacy)."
end

# make sure we don't have [, 'foo=bar'] which breaks us later.
if agent_config_args[0].nil?
  agent_config_args_full = [feature_plan_arg]
else
  agent_config_args_full = agent_config_args + [feature_plan_arg]
end

agent_config_info_file = '/opt/threatstack/cloudsight/config/config.json'

# NOTE: We do not signal the cloudsight service to restart because the package
# takes care of this.  The workflow differs between fresh installation
# installation and upgrades.
package 'threatstack-agent' do
  options node['threatstack']['pkg_opts'] if node['threatstack']['pkg_opts']
  version node['threatstack']['version'] if node['threatstack']['version']
  action node['threatstack']['pkg_action']
end

# needed for handing `cloudsight config`
if File.exist? '/opt/threatstack/etc/version'
  agent_version = File.open('/opt/threatstack/etc/version').read
else
  agent_version = '0.0.0'
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
# default rule set (most like 'Base Rule Set')
cmd = ''
unless agent_config_args_full.empty?
  agent_config_args_full.each do |arg|
    cmd += "cloudsight config #{arg} ;"
  end
end
cmd += "cloudsight setup --deploy-key=#{deploy_key}"
cmd += " --hostname='#{node['threatstack']['hostname']}'" if node['threatstack']['hostname']
cmd += " #{node['threatstack']['agent_extra_args']}" if node['threatstack']['agent_extra_args'] != ''

# Handle ruleset management via here.
unless node['threatstack']['rulesets'].empty?
  node['threatstack']['rulesets'].each do |r|
    cmd += " --ruleset='#{r}'"

    # This file is maintained because the list of rulesets is not readily accessible
    # in a ThreatStack agent install, and we want to re-run the registration
    # process when the ruleset list changes.
    file '/opt/threatstack/etc/active_rulesets.txt' do
      content node['threatstack']['rulesets'].join("\n").concat("\n")
      mode '0644'
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
      command '/usr/bin/cloudsight stop'
      action :nothing
      subscribes :run, 'file[/opt/threatstack/etc/active_rulesets.txt]', :immediately
    end
  end
end

if node['threatstack']['configure_agent']
  # `cloudsight setup` resource runs `cloudsight config` if there is stuff to
  # configure.
  execute 'cloudsight setup' do
    command cmd
    action :run
    retries 3
    timeout 60
    ignore_failure node['threatstack']['ignore_failure']
    sensitive true
    not_if do
      ::File.exist?('/opt/threatstack/cloudsight/config/.audit') &&
        ::File.exist?('/opt/threatstack/cloudsight/config/.secret')
    end
  end

  # This block is for reconfiguring the agent after setup has been completed.
  unless agent_config_args_full.empty?
    require 'json'

    # We can only set one argument at a time to build a string of `cloudsight
    # config` commands per argument.
    cloudsight_config_cmds = []
    unless agent_config_args_full.empty?
      agent_config_args_full.each do |arg|
        cloudsight_config_cmds.push("cloudsight config #{arg}")
      end
    end
    cloudsight_config_cmd = cloudsight_config_cmds.join(' ; ')

    # agent 1.4.8 introduced the config.json file.  Before that we must use
    # the older cookie file.
    if agent_version < '1.4.8'
      file '/opt/threatstack/cloudsight/config/.config_args' do
        owner 'root'
        group 'root'
        mode '0644'
        content agent_config_args_full.join(' ')
        # if agent_version is 0.0.0 then `cloudsight config` was run in
        # execute[cloudsight setup].
        notifies :run, 'execute[cloudsight configure]' unless agent_version == '0.0.0'
      end
      cloudsight_config_action = :nothing
    else
      cloudsight_config_action = :run
    end

    execute 'cloudsight configure' do
      command cloudsight_config_cmd
      action cloudsight_config_action
      retries 3
      timeout 60
      # We don't have agent_config_info_file until agent 1.4.8
      if agent_version >= '1.4.8'
        not_if do
          args_hash = JSON.parse(File.open(agent_config_info_file).read)
          no_changes = true
          agent_config_args_full.each do |arg|
            k, v = arg.split('=')
            # If this fails then just break out causing
            unless (args_hash.key? k) && (args_hash.fetch(k) == v.delete('"\''))
              no_changes = false
              break
            end
          end
          no_changes
        end
      end
      notifies :restart, 'service[cloudsight]', node['threatstack']['cloudsight_service_timer']
    end
  end
end

# NOTE: We do not signal the cloudsight service to restart via the package
# resource because the workflow differs between fresh installation and
# upgrades.  The package scripts will handle this.
if node['threatstack']['configure_agent'] == false
  node['threatstack']['cloudsight_service_action'].delete('start')
end
ruby_block 'manage cloudsight service' do
  block {}
  if node['threatstack']['cloudsight_service_action'].respond_to?(:each)
    node['threatstack']['cloudsight_service_action'].each do |action|
      notifies action, 'service[cloudsight]', node['threatstack']['cloudsight_service_timer']
    end
  else
    notifies node['threatstack']['cloudsight_service_action'], 'service[cloudsight]',
             node['threatstack']['cloudsight_service_timer']
  end
end
service 'cloudsight' do
  action :nothing
  supports restart: true
  stop_command 'service cloudsight stop; exit 0' # Because init script exits 3...
end
