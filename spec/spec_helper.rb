# spec_helper.rb
require 'chefspec'

RSpec.configure do |config|
  config.platform = 'ubuntu'
  config.version = '20.04'
end

ChefSpec::Coverage.start!
require 'chefspec/berkshelf'
