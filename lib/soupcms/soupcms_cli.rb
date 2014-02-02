require 'thor'
require 'yaml'
require 'json'
require 'mongo'

class SoupCMSCLI < Thor
  include Thor::Actions

  desc 'new <name>', 'create new application'
  method_option :generate, type: :boolean, aliases: '-g', default: false, desc: 'Generate NEW soupcms application. Default is false.'
  def new(name)
    configs = {}
    configs[:blog] = yes?('Blog support? (y/n):', :green)
    if configs[:blog]
      say('Choose blog layout?',:green)
      blog_layouts = [[1, 'full-width'], [2, 'right-sidebar'], [3, 'left-sidebar']]
      print_table blog_layouts
      layout = ask('layout? :', :limited_to => %w(1 2 3))
      configs[:blog_layout] = blog_layouts[layout.to_i - 1][1]
    end

    create_file "data/#{name}/_config.yml", YAML.dump(JSON.parse(configs.to_json))
    if configs[:blog]
      template 'lib/templates/my_first_post.tt',"data/#{name}/posts/my_first_post.md"
    end

  end

  desc 'clean <name>', 'clean all content from database'
  def clean(name)
    mongo_uri = ENV["MONGODB_URI_#{name}"] || "mongodb://localhost:27017/#{name}"
    conn = Mongo::MongoClient.from_uri(mongo_uri)
    db = conn.db
    say "Cleaning up the database '#{name}'", :green
    db.collection_names.each { |coll_name|
      next if coll_name.match(/^system/)
      say "Dropping collection '#{coll_name}'", :red
      db.drop_collection(coll_name)
    }
    conn.close
  end

  desc 'seed <name>', 'seed content to database'
  method_option :clean, type: :boolean, aliases: '-c', default: false, desc: 'Clean all documents before seed.'
  def seed(name)
    Dir.glob("data/#{name}/**/*.{json,md,yml}").each do |file|
      unless file.include?('ref_files') || file.include?('_config.yml')
        begin
          SoupCMS::CLI::Model::Base.create_model(File.new(file))
        rescue => e
          puts "Error importing file... #{file}"
          puts "#{e.backtrace.first}: #{e.message} (#{e.class})"
          puts "#{e.backtrace.drop(1).map{|s| s }.join("\n")}"
        end
      end
    end
  end

  def self.source_root
    File.join(File.dirname(__FILE__), '../..')
  end


end

