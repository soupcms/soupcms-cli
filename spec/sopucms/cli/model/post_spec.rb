require 'spec_helper'

describe SoupCMS::CLI::Model::Post do

  let (:db) { Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'soupcms-cli-test').database }
  let (:coll) { db.collection('posts') }
  let (:post_file) { File.new('spec/soupcms-cli-test/posts/structured-logging/structured-logging.md') }


  context 'create new object in posts collection using markdown' do

    it 'one object' do
      SoupCMS::CLI::Model::Post.new(post_file).create
      docs = coll.find({'doc_id' => 'structured-logging'}).to_a
      expect(docs.size).to eq(1)
    end

    it 'with slug and content' do
      SoupCMS::CLI::Model::Post.new(post_file).create

      docs = coll.find({'doc_id' => 'structured-logging'}).to_a
      expect(docs[0]['slug']).to eq('structured-logging')
      expect(docs[0]['content']['flavor']).to eq('kramdown')
      expect(docs[0]['content']['value']).to eq('# Lets first look at what we need to follow while logging to achieve structured logging.')
    end

    it 'add front matter' do
      SoupCMS::CLI::Model::Post.new(post_file).create

      docs = coll.find({'doc_id' => 'structured-logging'}).to_a
      expect(docs[0]['description']).to eq('Structured Logging is new technique of log messages to parse and query logs.')
      expect(docs[0]['publish_datetime']).to eq(1409961607)
      expect(docs[0]['tags']).to eq(%w(software-development logging))
      expect(docs[0]['title']).to eq('Structured Logging')
    end

    it 'should create object in posts collection with images' do
      SoupCMS::CLI::Model::Post.new(post_file).create

      docs = coll.find({'doc_id' => 'structured-logging'}).to_a
      expect(docs[0]['hero_image']).to eq('ref:images:posts/structured-logging/structured-logging.svg')

    end

  end






end