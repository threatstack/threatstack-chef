#
# Cookbook Name:: threatstack
# Recipe:: rhel
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

command = <<~SRV
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

remote_file node['threatstack']['repo']['key_file'] do
  source node['threatstack']['repo']['key']
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

yum_repository 'threatstack' do
  description 'Threat Stack Package Repository'
  baseurl node['threatstack']['repo']['url']
  gpgkey node['threatstack']['repo']['key_file_uri']
  action :add
end
