require 'rspec'
require 'soupcms/cli'
require 'mongo'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

$global_log_level = Logger::WARN

RSpec.configure do |config|
  config.order = 'random'
  config.expect_with :rspec

  config.before(:each) do
    db = Mongo::MongoClient.new('localhost', 27017).db('soupcms-cli-test')
    db.collection_names.each do |collection_name|
      next if collection_name.match(/^system/)
      db.collection(collection_name).remove
    end
  end

end
