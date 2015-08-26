require 'spec_helper'

describe 'threatstack::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['threatstack']['deploy_key'] = "ABCD1234"
    end.converge(described_recipe)
  end

  it 'includes the threatstack::repo recipe' do
    expect(chef_run).to include_recipe('threatstack::repo')
  end

  it 'installs the threatstack-agent package' do
    expect(chef_run).to install_package('threatstack-agent')
  end

  it 'executes the cloudsight setup' do
    expect(chef_run).to run_execute('cloudsight setup').with(
      command: "cloudsight setup --deploy-key=ABCD1234 --ruleset='Base Rule Set'"
    )
  end
end
