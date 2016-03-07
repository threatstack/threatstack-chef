require 'spec_helper'

describe 'threatstack::default' do
  context 'single-ruleset-test' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['threatstack']['rulesets'] = ['Base Rule Set']
      end.converge(described_recipe)
    end

    before do
      contents = { 'deploy_key' => 'ABCD1234' }
      allow(Chef::EncryptedDataBagItem).to receive(:load).with('threatstack', 'api_keys').and_return(contents)
    end

    it 'creates a ruleset file' do
      expect(chef_run).to render_file('/opt/threatstack/etc/active_rulesets.txt').with_content("Base Rule Set\n")
    end

    it 'does not touch the flag file' do
      resource = chef_run.file('/opt/threatstack/cloudsight/config/.secret')
      expect(resource).to do_nothing
    end

    it 'does not stop threatstack services' do
      resource = chef_run.execute('stop threatstack services')
      expect(resource).to do_nothing
    end

    it 'executes the cloudsight setup' do
      expect(chef_run).to run_execute('cloudsight setup').with(
        command: "cloudsight setup --deploy-key=ABCD1234 --ruleset='Base Rule Set'"
      )
    end
  end

  context 'explicit-deploy-key' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['threatstack']['deploy_key'] = 'EFGH5678'
        node.set['threatstack']['rulesets'] = ['Base Rule Set']
      end.converge(described_recipe)
    end

    it 'prefers the explicit deploy_key when one is specified' do
      expect(chef_run).to run_execute('cloudsight setup').with(
        command: "cloudsight setup --deploy-key=EFGH5678 --ruleset='Base Rule Set'"
      )
    end
  end

  context 'multi-ruleset-test' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['threatstack']['deploy_key'] = 'ABCD1234'
        node.set['threatstack']['rulesets'] = %w(base ubuntu cassandra)
      end.converge(described_recipe)
    end

    it 'stores all rulesets into a file' do
      expect(chef_run).to render_file('/opt/threatstack/etc/active_rulesets.txt').with_content("base\nubuntu\ncassandra\n")
    end

    it 'executes the cloudsight setup with multiple rulesets' do
      expect(chef_run).to run_execute('cloudsight setup').with(
        command: "cloudsight setup --deploy-key=ABCD1234 --ruleset='base' --ruleset='ubuntu' --ruleset='cassandra'"
      )
    end
  end

  context 'ruleset-configuration-changes' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['threatstack']['deploy_key'] = 'ABCD1234'
        node.set['threatstack']['rulesets'] = %w(base enhanced)
      end.converge(described_recipe)
    end

    before(:each) do
      allow(File).to receive(:exists?).with(anything).and_call_original
      allow(File).to receive(:exists?).with('/opt/threatstack/etc/active_rulesets.txt').and_return true
      allow(File).to receive(:read).with(anything).and_call_original
      allow(File).to receive(:read).with('/opt/threatstack/etc/active_rulesets.txt').and_return "base\n"
    end

    it 'deletes the flag file' do
      resource = chef_run.file('/opt/threatstack/etc/active_rulesets.txt')
      expect(resource).to notify('file[/opt/threatstack/cloudsight/config/.secret]').to(:delete).immediately
    end

    it 'stops threatstack' do
      resource = chef_run.file('/opt/threatstack/etc/active_rulesets.txt')
      expect(resource).to notify('execute[stop threatstack services]').to(:run).immediately
    end

    it 're-runs cloudsight setup' do
      expect(chef_run).to run_execute('cloudsight setup')
    end
  end

  context 'hostname-test' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['threatstack']['deploy_key'] = 'ABCD1234'
        node.set['threatstack']['hostname'] = 'test_server-i-abc123'
      end.converge(described_recipe)
    end

    it 'executes the cloudsight setup with a configured hostname' do
      expect(chef_run).to run_execute('cloudsight setup').with(
        command: "cloudsight setup --deploy-key=ABCD1234 --hostname='test_server-i-abc123'"
      )
    end
  end

  context 'install-apt-package' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04'
      ) do |node|
        node.set['threatstack']['deploy_key'] = 'ABCD1234'
      end.converge(described_recipe)
    end

    it 'installs the threatstack-agent package on ubuntu' do
      expect(chef_run).to install_package('threatstack-agent')
    end
  end

  context 'install-yum-package' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'redhat',
        version: '6.6'
      ) do |node|
        node.set['threatstack']['deploy_key'] = 'ABCD1234'
      end.converge(described_recipe)
    end

    it 'installs the threatstack-agent package on redhat' do
      expect(chef_run).to install_package('threatstack-agent')
    end
  end

  context 'uninstall-test' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['threatstack']['pkg_action'] = :remove
      end.converge(described_recipe)
    end

    before do
      contents = { 'deploy_key' => 'ABCD1234' }
      allow(Chef::EncryptedDataBagItem).to receive(:load).with('threatstack', 'api_keys').and_return(contents)
    end

    it 'uninstalls the package' do
      expect(chef_run).to remove_package('threatstack-agent')
    end

    it 'does not run unnecessary actions' do
      expect(chef_run).to_not create_file('/opt/threatstack/etc/active_rulesets.txt')
      expect(chef_run).to_not run_execute('cloudsight setup')
    end
  end
end
