# Encoding: utf-8
require 'serverspec'

set :backend, :exec

describe package('threatstack-agent') do
  it { should be_installed }
end

describe service('cloudsight') do
  it { should be_enabled }
end

describe service('cloudsight') do
  it { should be_running }
end

describe service('tsfim') do
  it { should be_running }
end

describe service('tsauditd') do
  it { should be_running }
end

describe file('/opt/threatstack/cloudsight/config/.secret') do
  it { should be_file }
end
