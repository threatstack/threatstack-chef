source 'https://rubygems.org'

gem 'chefspec', '= 7.1.1'
gem 'berkshelf', '= 6.3.1'
gem 'rubocop', '= 0.52.1'
gem 'foodcritic', '= 13.1.1'
gem 'cucumber-core', '= 3.2.1'
gem 'serverspec', '= 2.41.3'
gem 'stove', '= 6.0.0'
gem 'test-kitchen', '= 1.20.0'
gem 'kitchen-vagrant', '= 1.3.0'

if chefversion = ENV['CHEF_VERSION']
  gem 'chef', chefversion
else
  gem 'chef'
end
