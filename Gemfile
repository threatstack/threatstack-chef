source 'https://rubygems.org'

gem 'chefspec', '= 7.3.4'
gem 'berkshelf', '= 6.3.1'
gem 'rubocop', '= 0.61.1'
gem 'foodcritic', '= 15.1.0'
gem 'cucumber-core', '= 3.2.1'
gem 'serverspec', '= 2.41.3'
gem 'stove', '= 6.1.1'
gem 'test-kitchen', '= 1.20.0'
gem 'kitchen-vagrant', '= 1.5.0'
gem 'kitchen-ec2'

if chefversion = ENV['CHEF_VERSION']
  gem 'chef', chefversion
else
  gem 'chef'
end
