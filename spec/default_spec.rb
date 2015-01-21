require 'spec_helper'

describe 'threatstack::default' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'includes the threatstack::repo recipe' do
    expect(chef_run).to include_recipe("threatstack::repo")
  end
end
