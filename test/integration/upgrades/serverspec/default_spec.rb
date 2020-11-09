require 'serverspec'

set :backend, :exec

# Version to expect on install. Change this when we bump versions
current_version = '2.3.0'

describe package('threatstack-agent') do
  it { should be_installed }
end

# Check version
describe 'package version' do
  # How we can verify what is installed is what is defined to be installed
  #
  # IMPORTANT: Must set node.override['threatstack']['version'] in
  # `test/cookbooks/install_old_agent/attributes/default.rb` for test to pass!
  #
  # See: http://www.hurryupandwait.io/blog/accessing-chef-node-attributes-from-kitchen-tests
  let(:node) { JSON.parse(IO.read('/tmp/chef_node_for_tests.json')) }
  let(:current_version) { node['threatstack'] }

  it 'is running the current version' do
    if os[:family] == 'ubuntu'
      expect(command("dpkg-query -f '${Status} ${Version}' -W threatstack-agent").stdout).to match("^(install|hold) ok installed #{current_version}.*$")
    elsif os[:family] == 'redhat'
      expect(command("repoquery --qf '%{version}' threatstack-agent").stdout.strip).to eq(current_version) # rubocop: disable Style/FormatStringToken
    end
  end
end

describe service('threatstack') do
  it { should be_running }
  it { should be_enabled }
end

describe command('tsagent status') do
  # Sometimes due to other services, like auditd, the install would be successful, but then this service would get killed
  its(:stdout) { should match /UP Threat Stack Audit Collection/ } # rubocop: disable Lint/AmbiguousRegexpLiteral
end
