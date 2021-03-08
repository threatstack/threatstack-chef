#
# Cookbook:: threatstack
# Library:: helper
#
# Copyright:: 2014-2021, Threat Stack
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

def tsagent_info?(maj, min, patch)
  return true if (maj >= 2 && min >= 2) || (maj >= 2 && min >= 1 && patch >= 3)

  false
end

def unregistered_agent?
  require 'open3'
  require 'yaml'
  require 'date'

  # By the time this helper is hit, tsagent should exist - but, for tests it does not.
  # Fair to say that the agent is *definitely* unregistered if tsagent isnt installed :)
  return true unless ::File.exist?('/usr/bin/tsagent')

  stdout, = Open3.capture3('/usr/bin/tsagent info')
  stdout.gsub!("\t", '  ')
  tsagent_info = YAML.safe_load(stdout)

  return true if tsagent_info['LastBackendConnection'] == 'N/A'

  # It could be stale if it last connected >24h ago. Would need to exec tsagent status and search
  # for "UP Threat Stack Backend Connection" along with this to know for sure.
  # return true if (DateTime.now.to_time - tsagent_info['LastBackendConnection']) / 3600 > 24.0

  # otherwise, probably fresh.
  false
end
