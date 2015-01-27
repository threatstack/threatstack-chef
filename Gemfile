source 'https://rubygems.org'

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :development, :unit_tests do
  gem 'chef',       :require => false
  gem 'chefspec',   :require => false
  gem 'berkshelf',  :require => false
  gem 'rubocop',    :require => false
  gem 'foodcritic', :require => false
end

group :system_tests do
  gem 'serverspec',   :require => false
  gem 'test-kitchen', :require => false
end

if chefversion = ENV['CHEF_VERSION']
  gem 'chef', chefversion, :require => false
else
  gem 'chef', :require => false
end
