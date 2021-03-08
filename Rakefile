require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'cookstyle'

# Style tests. Cookstyle combines foodcritic and rubocop.
namespace :style do
  RuboCop::RakeTask.new(:cookstyle) do |task|
    task.options << '--display-cop-names'
  end
end

desc 'Run all style checks'
task style: ['style:cookstyle']

# Rspec and ChefSpec
desc "Run ChefSpec examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--format documentation'
end

# Default
task default: ['style', 'spec']
