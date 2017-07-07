# Encoding: utf-8

require 'serverspec'

set :backend, :exec

describe package('threatstack-agent') do
  it { should be_installed }
end

describe service('cloudsight') do
  it { should be_enabled }
end
