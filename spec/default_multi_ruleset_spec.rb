require 'spec_helper'

describe 'threatstack::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['threatstack']['deploy_key'] = "ABCD1234"
      node.set['threatstack']['rulesets'] = ['base', 'ubuntu', 'cassandra']
    end.converge(described_recipe)
  end

  it 'executes the cloudsight setup with list of rulesets' do
    expect(chef_run).to run_execute('cloudsight setup').with(
      command: "cloudsight setup --deploy-key=ABCD1234 --ruleset='base' --ruleset='ubuntu' --ruleset='cassandra'"
    )
  end
end
