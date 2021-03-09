require 'spec_helper'

describe 'threatstack::default' do
  context 'single-ruleset-test' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['threatstack']['rulesets'] = ['Base Rule Set']
      end.converge(described_recipe)
    end

    before do
      contents = { 'deploy_key' => 'ABCD1234' }
      stub_data_bag_item('threatstack', 'api_keys').and_return(contents)
    end

    it 'executes the ts setup' do
      expect(chef_run).to run_execute('tsagent setup').with(
        command: "tsagent setup --deploy-key=ABCD1234 --ruleset='Base Rule Set'"
      )
    end
  end

  context '1.x version' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['threatstack']['rulesets'] = ['Base Rule Set']
        node.normal['threatstack']['version'] = '1.9.0ubuntuBlergh'
      end
    end

    before do
      contents = { 'deploy_key' => 'ABCD1234' }
      stub_data_bag_item('threatstack', 'api_keys').and_return(contents)
    end

    it 'should raise a cookbook deprecation error for agent 1.x' do
      # Error message should say something about deprecation and the agent version
      expect{ chef_run.converge(described_recipe) } .to raise_error(NotImplementedError, /Deprecation.*agent version/)
    end
  end

  context '2.x version' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['threatstack']['rulesets'] = ['Base Rule Set']
        node.normal['threatstack']['version'] = '2.blahblah'
      end
    end

    before do
      contents = { 'deploy_key' => 'ABCD1234' }
      stub_data_bag_item('threatstack', 'api_keys').and_return(contents)
    end

    it 'should NOT raise a cookbook deprecation error for agent 2.x' do
      # Error message should say something about deprecation and the agent version
      expect{ chef_run.converge(described_recipe) } .not_to raise_error
    end
  end

  context 'explicit-deploy-key' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['threatstack']['deploy_key'] = 'EFGH5678'
        node.normal['threatstack']['rulesets'] = ['Base Rule Set']
      end.converge(described_recipe)
    end

    it 'prefers the explicit deploy_key when one is specified' do
      expect(chef_run).to run_execute('tsagent setup').with(
        command: "tsagent setup --deploy-key=EFGH5678 --ruleset='Base Rule Set'"
      )
    end
  end

  context 'multi-ruleset-test' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
        node.normal['threatstack']['rulesets'] = ['Base Rule Set', 'CloudTrail Base Rule Set']
      end.converge(described_recipe)
    end

    it 'executes the tsagent setup with multiple rulesets' do
      expect(chef_run).to run_execute('tsagent setup').with(
        command: "tsagent setup --deploy-key=ABCD1234 --ruleset='Base Rule Set,CloudTrail Base Rule Set'"
      )
    end
  end

  context 'enable-containers' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['threatstack']['enable_containers'] = true
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
      end.converge(described_recipe)
    end

    it 'enables container observation via tsagent config' do
      expect(chef_run).to render_file('/opt/threatstack/etc/chef_args_cache.txt').with_content(
        'tsagent config --set enable_containers 1;'
      )
    end
  end

  context 'dont-enable-containers-when-attr-false' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['threatstack']['enable_containers'] = false
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
      end.converge(described_recipe)
    end

    it 'doesnt enable container observation when attr is false' do
      expect(chef_run).to_not render_file('/opt/threatstack/etc/chef_args_cache.txt').with_content(
        'tsagent config --set enable_containers 1;'
      )
    end
  end

  context 'dont-enable-containers-when-attr-nil' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['threatstack']['enable_containers'] = nil
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
      end.converge(described_recipe)
    end

    it 'doesnt enable container observation when attr nil' do
      expect(chef_run).to_not render_file('/opt/threatstack/etc/chef_args_cache.txt').with_content(
        'tsagent config --set enable_containers 1;'
      )
    end
  end


  context 'agent-extra-args' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
        node.normal['threatstack']['agent_config_args'] = ['foo 1', 'bar 1']
      end.converge(described_recipe)
    end

    it 'sets tsagent config' do
      expect(chef_run).to render_file('/opt/threatstack/etc/chef_args_cache.txt').with_content(
        'tsagent config --set foo 1; tsagent config --set bar 1;'
      )
    end

    it 'notifies tsagent config from the file resource' do
      args_file = chef_run.file('/opt/threatstack/etc/chef_args_cache.txt')
      expect(args_file).to notify('execute[tsagent config]')
    end

    it 'still runs setup' do
      expect(chef_run).to run_execute('tsagent setup').with(
        command: "tsagent setup --deploy-key=ABCD1234"
      )
    end
  end

  context 'no agent-extra-args' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
      end.converge(described_recipe)
    end

    it 'does not write to config cache file' do
      expect(chef_run).to_not render_file('/opt/threatstack/etc/chef_args_cache.txt')
    end

    it 'does not run tsagent config by default' do
      expect(chef_run).to_not run_execute('tsagent config')
    end

    it 'still runs setup' do
      expect(chef_run).to run_execute('tsagent setup').with(
        command: "tsagent setup --deploy-key=ABCD1234"
      )
    end
  end

  context 'install only' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
        node.normal['threatstack']['install_only'] = true
      end.converge(described_recipe)
    end

    it 'does not write to config cache file' do
      expect(chef_run).to_not render_file('/opt/threatstack/etc/chef_args_cache.txt')
    end

    it 'does not run tsagent config by default' do
      expect(chef_run).to_not run_execute('tsagent config')
    end

    it 'does not run setup' do
      expect(chef_run).to_not run_execute('tsagent setup').with(
        command: "tsagent setup --deploy-key=ABCD1234"
      )
    end

    it 'still installs the agent' do
      expect(chef_run).to upgrade_package('threatstack-agent')
    end
  end

  context 'hostname-test' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
        node.normal['threatstack']['hostname'] = 'test_server-i-abc123'
      end.converge(described_recipe)
    end

    it 'executes the tsagent setup with a configured hostname' do
      expect(chef_run).to run_execute('tsagent setup').with(
        command: "tsagent setup --deploy-key=ABCD1234 --hostname='test_server-i-abc123'"
      )
    end
  end

  context 'upgrade-apt-package when no version is specified' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '16.04'
      ) do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
      end.converge(described_recipe)
    end

    it 'installs or upgrades the threatstack-agent package on ubuntu' do
      expect(chef_run).to upgrade_package('threatstack-agent')
    end
  end

  context 'install-apt-package when specific version is specified' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '18.04'
      ) do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
        node.normal['threatstack']['version'] = '2.0.0.0ubuntu18.56'
      end.converge(described_recipe)
    end

    it 'installs the threatstack-agent package on ubuntu' do
      expect(chef_run).to install_package('threatstack-agent')
    end
  end

  context 'upgrade-yum-package when no version is specified' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'redhat',
        version: '7.4'
      ) do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
      end.converge(described_recipe)
    end

    it 'installs the threatstack-agent package on redhat' do
      expect(chef_run).to upgrade_package('threatstack-agent')
    end
  end
end
