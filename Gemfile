source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :development, :unit_tests , :test do
  gem 'rake', "13.0.3",         :require => false
  gem 'chefspec', '= 7.3.4',    :require => false
  gem 'berkshelf', '= 6.3.4'
  gem 'cookstyle', '= 6.16.10'
end

group :system_tests do
  gem 'serverspec',         :require => false
  gem 'test-kitchen',       :require => false
  gem 'kitchen-docker',     :require => false
  gem 'kitchen-ec2',        :require => false
end

if chefversion = ENV['CHEF_VERSION']
  gem 'chef', chefversion
else
  gem 'chef'
end
