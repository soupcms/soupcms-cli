require 'yaml'
require 'mongo'
require 'json'
require 'logger'

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
            when 'svg', 'png', 'jpeg', 'jpg'
              image_name = File.basename(file).split('.')[1]
              case image_name
                when 'mobile'
                  SoupCMS::CLI::Model::MobileImage.new(file).create
                when 'tablet'
                  SoupCMS::CLI::Model::TabletImage.new(file).create
                else
                  SoupCMS::CLI::Model::Image.new(file).create
              end
          end
        end

        SEVERITY_COLOR_MAP = { 'INFO' => :green,'DEBUG' => :yellow}
        def initialize(file);
          @file = file;
          @logger = Logger.new(STDOUT)
          @logger.level = $global_log_level || (ENV['verbose'] == 'true' ? Logger::DEBUG : Logger::INFO)
          @logger.formatter = proc do |severity, datetime, progname, msg|
            "#{severity}: #{msg}\n".colorize(SEVERITY_COLOR_MAP[severity] || :red)
          end
        end

        attr_reader :file

        def conn
          return @conn if @conn
          mongo_uri = ENV["MONGODB_URI_#{app_name}"] || ENV["MONGOLAB_URI"] || "mongodb://localhost:27017/#{app_name}"
          @conn = Mongo::Client.new(mongo_uri)
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
          conn.database
        end

        def coll;
          db[model]
        end

        def hero_image
          Dir.glob("#{File.dirname(@file)}/**/#{doc_name}.{svg,png,jpg,jpeg}").each do |image_file|
            return "ref:images:#{SoupCMS::CLI::Model::Image.new(File.new(image_file)).doc_id}"
          end
          return nil
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
          coll.find({'_id' => old_doc['_id']}).update_one({'$set' => {'latest' => false, 'state' => 'published_archive'}}) unless old_doc.empty?
        end

        def build
          doc['doc_id'] = doc_name unless doc['doc_id']

          timestamp = file.mtime.to_i

          doc['publish_datetime'] = doc['publish_datetime'].to_i || timestamp
          doc['version'] = timestamp unless doc['version']
          doc['locale'] = 'en_US' unless doc['locale']
          doc['update_datetime'] = timestamp
          doc['create_datetime'] = (old_doc.empty? ? timestamp : old_doc['create_datetime'])
          doc['create_by'] = 'seed' unless doc['create_by']

          doc['state'] = publish_in_future? ? 'draft' : 'published' unless doc['state']
          doc['latest'] = true unless doc['latest']

          doc['slug'] = slug unless doc['slug']
          doc['hero_image'] = hero_image if hero_image
        end

        def publish_in_future?
          doc['publish_datetime'] > Time.now.to_i
        end

        def create
          build
          if doc['update_datetime'] == old_doc['update_datetime']
            @logger.debug "Skipping document '#{file.path}' since no changes"
          else
            @logger.info "Inserting document '#{file.path}'"
            @logger.debug "\n #{JSON.pretty_generate(doc)}"
            coll.insert_one(doc)
            update_old_doc
          end
        end


      end


    end
  end
end
