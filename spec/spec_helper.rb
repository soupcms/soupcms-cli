require 'rspec'
require 'soupcms/cli'

RSpec.configure do |config|
  config.order = 'random'
  config.expect_with :rspec

  config.before(:suite) do
  end

  config.before(:each) do
  end

  config.after(:suite) do
  end

end
