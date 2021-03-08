#
# Cookbook Name:: threatstack
# Library:: helper
#
# Copyright 2014-2021, Threat Stack
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

def has_tsagent_info(maj, min, patch)
  return true if (maj >= 2 && min >= 2) || (maj >= 2 && min >= 1 && patch >= 3)
  false
end

def ts_down?
  require 'open3'
  stdout, = Open3.capture3('/usr/bin/tsagent status')
  !stdout.include?('UP Threat Stack Backend Connection')
end

def unregistered_agent?
  require 'open3'
  require 'yaml'
  require 'date'
  stdout, = Open3.capture3('/usr/bin/tsagent info')
  stdout.gsub!("\t", '  ')
  tsagent_info = YAML.safe_load(stdout)

  return true if tsagent_info['LastBackendConnection'] == 'N/A'

  # It could be stale if it last connected >24h ago. Would need to get ts_down? to know for sure.
  # This is an option for folks if they leave machines off for 24h or more, but it might be a better
  # function for a wrapper cookbook of some sort.
  #return true if (DateTime.now.to_time - tsagent_info['LastBackendConnection']) / 3600 > 24.0

  # otherwise, probably fresh.
  false
end
