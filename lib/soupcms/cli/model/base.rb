require 'yaml'
require 'mongo'
require 'json'

module SoupCMS
  module CLI
    module Model

      class Base

        def self.create_model(file)
          type = File.basename(file).split('.').last
          model = file.path.split('/')[2]
          case type
            when 'json'
              SoupCMS::CLI::Model::Base.new(file).create
            when 'yml'
              SoupCMS::CLI::Model::Yaml.new(file).create
            when 'md'
              case model
                when 'posts'
                  SoupCMS::CLI::Model::Post.new(file).create
                when 'chapters'
                  SoupCMS::CLI::Model::Chapter.new(file).create
                when 'pages'
                  SoupCMS::CLI::Model::Page.new(file).create
                else
                  SoupCMS::CLI::Model::Markdown.new(file).create
              end
          end
        end

        def initialize(file)
          ; @file = file;
        end

        attr_reader :file

        def conn
          return @conn if @conn
          mongo_uri = ENV["MONGODB_URI_#{app_name}"] || "mongodb://localhost:27017/#{app_name}"
          @conn = Mongo::MongoClient.from_uri(mongo_uri)
        end

        def doc_name;
          File.basename(file).split('.').first
        end

        def slug;
          doc['slug'] || doc_name
        end

        def type;
          File.basename(file).split('.').last
        end

        def model;
          file.path.split('/')[2]
        end

        def app_name;
          file.path.split('/')[1]
        end

        def db;
          conn.db
        end

        def coll;
          db[model]
        end

        def hero_image
          image_path = File.join(File.dirname(__FILE__), '../../../../public', app_name, model, "images/#{doc_name}.*")
          hero_image = Dir.glob(image_path).to_a
          return File.join('/assets', app_name, model, 'images', File.basename(hero_image[0])) unless hero_image.empty?
        end

        def doc;
          @doc ||= parse_file
        end

        def parse_file
          document_hash = JSON.parse(file.read)
          SoupCMS::CLI::ResolveFileReference.new(File.dirname(file)).parse(document_hash)
        end

        def old_doc
          @old_doc ||= (coll.find({'doc_id' => doc['doc_id'], 'latest' => true}).to_a[0] || {})
        end

        def update_old_doc
          coll.update({'_id' => old_doc['_id']}, {'$set' => {'latest' => false, 'state' => 'published_archive'}}) unless old_doc.empty?
        end

        def build
          doc['doc_id'] = doc_name unless doc['doc_id']

          timestamp = file.mtime.to_i
          doc['publish_datetime'] = timestamp unless doc['publish_datetime']
          doc['version'] = timestamp unless doc['version']
          doc['locale'] = 'en_US' unless doc['locale']
          doc['create_datetime'] = (old_doc.empty? ? timestamp : old_doc['create_datetime'])
          doc['create_by'] = 'seed' unless doc['create_by']

          doc['state'] = 'published' unless doc['state']
          doc['latest'] = true unless doc['latest']

          doc['slug'] = slug unless doc['slug']
          doc['hero_image'] = {'url' => hero_image} if hero_image
        end

        def create
          build
          if doc['publish_datetime'] == old_doc['publish_datetime']
            #puts "Skipping document #{file}, since no changes"
          else
            puts "Inserting document #{file.path}"
            coll.insert(doc)
            update_old_doc
          end
          conn.close
        end


      end


    end
  end
end
