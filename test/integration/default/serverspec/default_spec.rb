# Encoding: utf-8
# frozen_string_literal: true
require 'serverspec'

set :backend, :exec

describe package('threatstack-agent') do
  it { should be_installed }
end

describe service('cloudsight') do
  it { should be_enabled }
end
