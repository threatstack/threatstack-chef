require 'spec_helper'

describe 'threatstack::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['threatstack']['deploy_key'] = "ABCD1234"
      node.set['threatstack']['hostname'] = "test_server-i-abc123"
    end.converge(described_recipe)
  end

  it 'executes the cloudsight setup with a configured hostname' do
    expect(chef_run).to run_execute('cloudsight setup').with(
      command: "cloudsight setup --deploy-key=ABCD1234 --hostname='test_server-i-abc123' --ruleset='Base Rule Set'"
    )
  end
end
