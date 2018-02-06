source 'https://rubygems.org'

gem 'chefspec', '= 6.2.0'
gem 'berkshelf', '= 5.6.5'
gem 'rubocop', '= 0.49.1'
gem 'foodcritic', '= 11.2.0'
gem 'serverspec', '= 2.37.1'
gem 'stove', '= 5.2.0'
gem 'test-kitchen', '= 1.20.0'
gem 'kitchen-vagrant', '= 1.3.0'

if chefversion = ENV['CHEF_VERSION']
  gem 'chef', chefversion
else
  gem 'chef'
end
