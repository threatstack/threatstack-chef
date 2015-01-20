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

case node['platform_family']
when 'debian'
  apt_repository 'threatstack' do
    uri "#{node['threatstack']['repo']}/Ubuntu"
    distribution node['lsb']['codename']
    components ['main']
    key 'https://www.threatstack.com/APT-GPG-KEY-THREATSTACK'
    action :add
  end

when 'rhel'
  if node['platform'] == 'amazon'
    path = 'Amazon'
  else
    path = 'CentOS'
  end

  yum_repository 'threatstack' do
    description 'Threat Stack'
    baseurl "#{node['threatstack']['repo']}/#{path}"
    gpgkey 'https://www.threatstack.com/RPM-GPG-KEY-THREATSTACK'
    action :add
  end
end
