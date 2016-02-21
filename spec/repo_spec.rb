require 'spec_helper'

describe 'threatstack::default' do
  context 'debian-wheezy' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'debian',
        version: '7.8'
      ) do |node|
        node.set['threatstack']['deploy_key'] = 'ABCD1234'
      end
      runner.converge(described_recipe)
    end

    it 'installs the apt-transport-http package' do
      expect(chef_run).to install_package('apt-transport-https')
    end

    it 'sets up the apt repository' do
      expect(chef_run).to add_apt_repository('threatstack').with(
        uri: 'https://pkg.threatstack.com/Ubuntu',
        distribution: 'wheezy',
        components: ['main'],
        key: 'https://app.threatstack.com/APT-GPG-KEY-THREATSTACK'
      )
    end
  end

  context 'ubuntu-lucid' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '10.04'
      ) do |node|
        node.set['threatstack']['deploy_key'] = 'ABCD1234'
      end
      runner.converge(described_recipe)
    end

    it 'sets up the apt repository' do
      expect(chef_run).to add_apt_repository('threatstack').with(
        uri: 'https://pkg.threatstack.com/Ubuntu',
        distribution: 'lucid',
        components: ['main'],
        key: 'https://app.threatstack.com/APT-GPG-KEY-THREATSTACK'
      )
    end
  end

  context 'ubuntu-precise' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '12.04'
      ) do |node|
        node.set['threatstack']['deploy_key'] = 'ABCD1234'
      end
      runner.converge(described_recipe)
    end

    it 'sets up the apt repository' do
      expect(chef_run).to add_apt_repository('threatstack').with(
        uri: 'https://pkg.threatstack.com/Ubuntu',
        distribution: 'precise',
        components: ['main'],
        key: 'https://app.threatstack.com/APT-GPG-KEY-THREATSTACK'
      )
    end
  end

  context 'ubuntu-trusty' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04'
      ) do |node|
        node.set['threatstack']['deploy_key'] = 'ABCD1234'
      end
      runner.converge(described_recipe)
    end

    it 'sets up the apt repository' do
      expect(chef_run).to add_apt_repository('threatstack').with(
        uri: 'https://pkg.threatstack.com/Ubuntu',
        distribution: 'trusty',
        components: ['main'],
        key: 'https://app.threatstack.com/APT-GPG-KEY-THREATSTACK'
      )
    end
  end

  context 'redhat' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'redhat',
        version: '6.5'
      ) do |node|
        node.set['threatstack']['deploy_key'] = 'ABCD1234'
      end
      runner.converge(described_recipe)
    end

    it 'sets up the yum repository' do
      expect(chef_run).to add_yum_repository('threatstack').with(
        description: 'Threat Stack',
        baseurl: 'https://pkg.threatstack.com/CentOS',
        gpgkey: 'https://app.threatstack.com/RPM-GPG-KEY-THREATSTACK'
      )
    end
  end

  context 'centos' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.5'
      ) do |node|
        node.set['threatstack']['deploy_key'] = 'ABCD1234'
      end
      runner.converge(described_recipe)
    end

    it 'sets up the yum repository' do
      expect(chef_run).to add_yum_repository('threatstack').with(
        description: 'Threat Stack',
        baseurl: 'https://pkg.threatstack.com/CentOS',
        gpgkey: 'https://app.threatstack.com/RPM-GPG-KEY-THREATSTACK'
      )
    end
  end

  context 'amazon' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'amazon',
        version: '2012.09'
      ) do |node|
        node.set['threatstack']['deploy_key'] = 'ABCD1234'
      end
      runner.converge(described_recipe)
    end

    it 'sets up the yum repository' do
      expect(chef_run).to add_yum_repository('threatstack').with(
        description: 'Threat Stack',
        baseurl: 'https://pkg.threatstack.com/Amazon',
        gpgkey: 'https://app.threatstack.com/RPM-GPG-KEY-THREATSTACK'
      )
    end
  end
end
