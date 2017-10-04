#
# Cookbook Name:: threatstack
# Recipe:: debian
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

package 'apt-transport-https'

apt_repository 'threatstack' do
  uri node['threatstack']['repo']['url']
  distribution node['threatstack']['repo']['dist']
  components node['threatstack']['repo']['components']
  key node['threatstack']['repo']['key']
  action :add
end
