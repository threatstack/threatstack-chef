# frozen_string_literal: true
# spec_helper.rb
require 'chefspec'

RSpec.configure do |config|
  config.platform = 'ubuntu'
  config.version = '14.04'
end

ChefSpec::Coverage.start!
require 'chefspec/berkshelf'
