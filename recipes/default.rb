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

command =<<-SRV
if [[ `/sbin/init --version` =~ upstart ]]; then echo upstart;
elif [[ `systemctl` =~ -\.mount ]]; then echo systemd;
elif [[ -f /etc/init.d/cron && ! -h /etc/init.d/cron ]]; then echo sysv-init;
else echo unknown;
fi
SRV
command_out = shell_out(command)
node.default['service_manager'] = command_out.stdout.strip

if node['service_manager'] == 'upstart'
    node.override['threatstack']['repo']['url'] = 'https://pkg.threatstack.com/v2/Amazon/1'
else
    node.override['threatstack']['repo']['url'] = 'https://pkg.threatstack.com/v2/Amazon/2'
end

unless node['threatstack']['version'].nil?
  if node['threatstack']['version'].start_with?('1.')
    error_string = "Deprecation Error: Unsupported agent version detected ( #{node['threatstack']['version']} ).\n"
    error_string += 'For agent versions < 2.0, use a previous version of this cookbook.'
    raise NotImplementedError, error_string
  end
end

if node['threatstack']['repo_enable']
  if platform_family?('fedora', 'amazon')
    include_recipe 'threatstack::rhel'
  else
    include_recipe "threatstack::#{node['platform_family']}"
  end
end

# Disable auditd on amazon linux 2, RHEL, and CentOS
execute 'stop_auditd' do # ~FC004 This is a workaround for auditd not stoppable with the standard method
  command 'service auditd stop'
  only_if { platform?('amazon') && node['service_manager'] != 'upstart' || platform?('centos', 'redhat') }
end

execute 'disable_auditd' do
  command 'systemctl disable auditd'
  only_if { platform?('amazon') && node['service_manager'] != 'upstart' || platform?('centos', 'redhat') }
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

include_recipe 'threatstack::agent_setup' unless node['threatstack']['install_only'] == true
