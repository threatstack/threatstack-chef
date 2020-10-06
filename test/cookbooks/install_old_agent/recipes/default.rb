#
# Cookbook Name:: install_old_agent
# Recipe:: default
#
# Copyright 2014-2020, Threat Stack
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

# Just install old agent, don't fire it up.
if node['threatstack']['repo_enable']
  if platform_family?('rhel', 'fedora', 'amazon')
    remote_file node['threatstack']['old_agent']['repo']['key_file'] do
      source node['threatstack']['old_agent']['repo']['key']
      owner 'root'
      group 'root'
      mode '0644'
      action :create
    end

    yum_repository 'threatstack-old-agent' do
      description 'Threat Stack Package Repository'
      baseurl node['threatstack']['old_agent']['repo']['url']
      gpgkey node['threatstack']['old_agent']['repo']['key_file_uri']
      gpgcheck node['threatstack']['old_agent']['validate_gpg_key']
      action :add
    end
  else
    package 'apt-transport-https'

    apt_repository 'threatstack-old-agent' do
      uri node['threatstack']['old_agent']['repo']['url']
      distribution node['threatstack']['old_agent']['repo']['dist']
      components node['threatstack']['old_agent']['repo']['components']
      key node['threatstack']['old_agent']['repo']['key']
      action :add
    end
  end
end

execute 'stop_auditd' do # ~FC004 This is a workaround for auditd not stoppable with the standard method
  command 'service auditd stop'
  only_if { platform?('amazon') && node['platform_version'] == '2' || platform?('centos', 'redhat') }
end

execute 'disable_auditd' do
  command 'systemctl disable auditd'
  only_if { platform?('amazon') && node['platform_version'] == '2' || platform?('centos', 'redhat') }
end

# Change this as more agent versions are released, in accordance with official support
# Hacky version logic to deal with debian systems
package 'threatstack-agent' do
  version platform_family?('rhel', 'fedora', 'amazon') ? node['threatstack']['old_version'] : node['threatstack']['old_version'] + '*'
  action :install
  notifies :run, 'execute[stop_auditd]', :before
  notifies :run, 'execute[disable_auditd]', :before
end

# How we can verify what is installed is what is defined to be installed
# See: http://www.hurryupandwait.io/blog/accessing-chef-node-attributes-from-kitchen-tests
ruby_block 'Save node attributes' do
  block do
    if Dir.exist?('/tmp/')
      IO.write('/tmp/chef_node_for_tests.json', node.to_json)
    end
  end
end
