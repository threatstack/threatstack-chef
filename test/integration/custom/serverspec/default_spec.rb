require 'serverspec'

set :backend, :exec

describe package('threatstack-agent') do
  it { should be_installed }
end

# Work around old service system in Amazon Linux 1
if os[:family] == 'amazon' && os[:release] != "2"

  describe command('sudo initctl status threatstack') do
    its(:stdout) { should match /threatstack start\/running/ } # rubocop: disable Lint/AmbiguousRegexpLiteral
  end

  describe service('threatstack') do
    it { should be_enabled }
  end
else
  describe service('threatstack') do
    it { should be_running }
    it { should be_enabled }
  end
end

describe command('tsagent config --list') do
  its(:stdout) { should match /log.maxSize=22/ } # rubocop: disable Lint/AmbiguousRegexpLiteral
end
