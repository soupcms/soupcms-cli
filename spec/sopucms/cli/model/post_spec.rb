require 'spec_helper'

describe SoupCMS::CLI::Model::Post do

  let (:db) { Mongo::MongoClient.new('localhost', 27017).db('soupcms-cli-test') }
  let (:coll) { db.collection('posts') }


  it 'should create desktop image entity in images collection' do
    post_file = File.new('spec/soupcms-cli-test/posts/structured-logging/structured-logging.md')

    SoupCMS::CLI::Model::Post.new(post_file).create

    docs = coll.find({'doc_id' => 'structured-logging'}).to_a
    expect(docs.size).to eq(1)
    doc = docs[0]
    expect(doc['slug']).to eq('structured-logging')
    expect(doc['description']).to eq('Structured Logging is new technique of log messages to parse and query logs.')
    expect(doc['publish_datetime']).to eq(1409961607)
    expect(doc['tags']).to eq(%w(software-development logging))
    expect(doc['title']).to eq('Structured Logging')
    expect(doc['content']['flavor']).to eq('kramdown')
    expect(doc['content']['value']).to eq('# Lets first look at what we need to follow while logging to achieve structured logging.')
  end

end