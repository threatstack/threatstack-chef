require 'spec_helper'

describe 'threatstack::default' do

  context 'debian-jessie' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'debian',
        version: '8.10'
      ) do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
      end
      runner.converge(described_recipe)
    end

    it 'installs the apt-transport-http package' do
      expect(chef_run).to install_package('apt-transport-https')
    end

    it 'sets up the apt repository' do
      expect(chef_run).to add_apt_repository('threatstack').with(
        distribution: 'jessie'
      )
    end
  end

  context 'debian-stretch' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'debian',
        version: '9.3'
      ) do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
      end
      runner.converge(described_recipe)
    end

    it 'installs the apt-transport-http package' do
      expect(chef_run).to install_package('apt-transport-https')
    end

    it 'sets up the apt repository' do
      expect(chef_run).to add_apt_repository('threatstack').with(
        distribution: 'stretch'
      )
    end
  end

  context 'ubuntu-xenial' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '16.04'
      ) do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
      end
      runner.converge(described_recipe)
    end

    it 'sets up the apt repository' do
      expect(chef_run).to add_apt_repository('threatstack').with(
        distribution: 'xenial'
      )
    end
  end

  context 'ubuntu-bionic' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '18.04'
      ) do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
      end
      runner.converge(described_recipe)
    end

    it 'sets up the apt repository' do
      expect(chef_run).to add_apt_repository('threatstack').with(
        distribution: 'bionic'
      )
    end

    it 'doesnt worry about auditd' do
      expect(chef_run).to_not run_execute('stop_auditd')
      expect(chef_run).to_not run_execute('disable_auditd')
    end
  end

  context 'redhat' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'redhat',
        version: '7.4'
      ) do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
      end
      runner.converge(described_recipe)
    end

    it 'downloads the threatstack repo key' do
      expect(chef_run).to create_remote_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-THREATSTACK')
    end

    it 'sets up the yum repository' do
      expect(chef_run).to add_yum_repository('threatstack').with(
        description: 'Threat Stack Package Repository',
        baseurl: 'https://pkg.threatstack.com/v2/EL/7',
        gpgkey: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-THREATSTACK'
      )
    end

    it 'stops and disables auditd' do
      expect(chef_run).to run_execute('stop_auditd')
      expect(chef_run).to run_execute('disable_auditd')
    end
  end

  context 'centos' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '7.4'
      ) do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
      end
      runner.converge(described_recipe)
    end

    it 'downloads the threatstack repo key' do
      expect(chef_run).to create_remote_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-THREATSTACK')
    end

    it 'sets up the yum repository' do
      expect(chef_run).to add_yum_repository('threatstack').with(
        description: 'Threat Stack Package Repository',
        baseurl: 'https://pkg.threatstack.com/v2/EL/7',
        gpgkey: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-THREATSTACK'
      )
    end
  end

  context 'amazon linux 1' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'amazon',
        version: '2017.09'
      ) do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
      end
      runner.converge(described_recipe)
    end

    it 'downloads the threatstack repo key' do
      expect(chef_run).to create_remote_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-THREATSTACK')
    end

    it 'sets up the yum repository' do
      expect(chef_run).to add_yum_repository('threatstack').with(
        description: 'Threat Stack Package Repository',
        baseurl: 'https://pkg.threatstack.com/v2/Amazon/1',
        gpgkey: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-THREATSTACK'
      )
    end
  end

  context 'amazon linux 2' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'amazon',
        version: '2'
      ) do |node|
        node.normal['threatstack']['deploy_key'] = 'ABCD1234'
      end
      runner.converge(described_recipe)
    end

    it 'downloads the threatstack repo key' do
      expect(chef_run).to create_remote_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-THREATSTACK')
    end

    it 'sets up the yum repository' do
      expect(chef_run).to add_yum_repository('threatstack').with(
        description: 'Threat Stack Package Repository',
        baseurl: 'https://pkg.threatstack.com/v2/Amazon/2',
        gpgkey: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-THREATSTACK'
      )
    end
    it 'stops and disables auditd' do
      expect(chef_run).to run_execute('stop_auditd')
      expect(chef_run).to run_execute('disable_auditd')
    end

  end
end
