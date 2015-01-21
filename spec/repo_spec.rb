require 'spec_helper'

describe 'threatstack::default' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'includes the threatstack::repo recipe' do
    expect(chef_run).to include_recipe('threatstack::repo')
  end

  it 'installs the threatstack-agent package' do
    expect(chef_run).to install_package('threatstack-agent')
  end

  it 'executes the cloudsight setup' do
    expect(chef_rum).to run_execute('cloudsight setup')
  end
end
