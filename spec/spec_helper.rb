require 'rspec'
require 'soupcms/cli'
require 'mongo'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

Mongo::Logger.logger.level = Logger::INFO
$global_log_level = Logger::WARN

RSpec.configure do |config|
  config.order = 'random'
  config.expect_with :rspec

  config.before(:each) do
    MongoDatabase.clean()
  end

end

class MongoDatabase

  def self.clean()
    @@db ||= Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'soupcms-cli-test').database
    @@db.collections.each do |collection|
      next if collection.name.match(/^system/)
      collection.drop
    end      
  end  

end  
