require 'spec_helper'

describe 'threatstack::repo' do
  context 'ubuntu-lucid' do
    let(:chef_run) do
      runner =  ChefSpec::SoloRunner.new(
        :platform => 'ubuntu',
        :version => '10.04'
      )
    runner.converge(described_recipe)
    end

    it 'sets up the apt repository' do
      expect(chef_run).to add_apt_repository('threatstack').with(
        uri: 'https://pkg.threatstack.com/Ubuntu',
        distribution: 'lucid',
        components: ['main'],
        key: 'https://www.threatstack.com/APT-GPG-KEY-THREATSTACK',
      )
    end
  end

  context 'ubuntu-precise' do
    let(:chef_run) do
      runner =  ChefSpec::SoloRunner.new(
        :platform => 'ubuntu',
        :version => '12.04'
      )
    runner.converge(described_recipe)
    end

    it 'sets up the apt repository' do
      expect(chef_run).to add_apt_repository('threatstack').with(
        uri: 'https://pkg.threatstack.com/Ubuntu',
        distribution: 'precise',
        components: ['main'],
        key: 'https://www.threatstack.com/APT-GPG-KEY-THREATSTACK',
      )
    end
  end

  context 'ubuntu-trusty' do
    let(:chef_run) do
      runner =  ChefSpec::SoloRunner.new(
        :platform => 'ubuntu',
        :version => '14.04'
      )
    runner.converge(described_recipe)
    end

    it 'sets up the apt repository' do
      expect(chef_run).to add_apt_repository('threatstack').with(
        uri: 'https://pkg.threatstack.com/Ubuntu',
        distribution: 'trusty',
        components: ['main'],
        key: 'https://www.threatstack.com/APT-GPG-KEY-THREATSTACK',
      )
    end
  end

  context 'redhat' do
    let(:chef_run) do
      runner =  ChefSpec::SoloRunner.new(
        :platform => 'redhat',
        :version => '6.5'
      )
    runner.converge(described_recipe)
    end

    it 'sets up the yum repository' do
      expect(chef_run).to add_yum_repository('threatstack').with(
        description: 'Threat Stack',
        baseurl: 'https://pkg.threatstack.com/CentOS',
        gpgkey: 'https://www.threatstack.com/RPM-GPG-KEY-THREATSTACK',
      )
    end
  end

  context 'centos' do
    let(:chef_run) do
      runner =  ChefSpec::SoloRunner.new(
        :platform => 'centos',
        :version => '6.5'
      )
    runner.converge(described_recipe)
    end

    it 'sets up the yum repository' do
      expect(chef_run).to add_yum_repository('threatstack').with(
        description: 'Threat Stack',
        baseurl: 'https://pkg.threatstack.com/CentOS',
        gpgkey: 'https://www.threatstack.com/RPM-GPG-KEY-THREATSTACK',
      )
    end
  end

  context 'amazon' do
    let(:chef_run) do
      runner =  ChefSpec::SoloRunner.new(
        :platform => 'amazon',
        :version => '2012.09'
      )
    runner.converge(described_recipe)
    end

    it 'sets up the yum repository' do
      expect(chef_run).to add_yum_repository('threatstack').with(
        description: 'Threat Stack',
        baseurl: 'https://pkg.threatstack.com/Amazon',
        gpgkey: 'https://www.threatstack.com/RPM-GPG-KEY-THREATSTACK',
      )
    end
  end


end
