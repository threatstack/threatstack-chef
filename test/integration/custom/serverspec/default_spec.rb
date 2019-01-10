require 'serverspec'

set :backend, :exec

describe package('threatstack-agent') do
  it { should be_installed }
end

describe service('threatstack') do
  it { should be_running }
  it { should be_enabled }
end

describe command('tsagent config --list') do
  its(:stdout) { should match /fim.log=yes/ } # rubocop: disable Lint/AmbiguousRegexpLiteral
end
