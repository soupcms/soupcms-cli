require 'rubygems'
require 'thor'
require 'yaml'
require 'json'
require 'mongo'

class SoupCMSCLI < Thor
  include Thor::Actions

  def initialize(*args)
    super
    @configs = {}
  end

  attr_reader :configs

  desc 'new <name>', 'create new application'
  method_option :generate, type: :boolean, aliases: '-g', default: false, desc: 'Generate NEW soupcms application. Default is false.'
  def new(name)
    configs[:name] = name
    configs[:display_name] = ask('Short display application name? (10 to 15 char) :', :green)
    configs[:description] = ask('Long application description? (30 to 40 char) :', :green)

    configs[:blog] = yes?('Blog support?:', :green)
    if configs[:blog]
      say('Choose blog layout?',:green)
      blog_layouts = [[1, 'full-width'], [2, 'right-sidebar'], [3, 'left-sidebar']]
      print_table blog_layouts
      layout = ask('choose from', :green, :limited_to => %w(1 2 3))
      configs[:blog_layout] = blog_layouts[layout.to_i - 1][1]
    end

    create_file "data/#{name}/_config.yml", YAML.dump(JSON.parse(configs.to_json))
    if configs[:blog]
      template 'lib/templates/pages/blog-post.yml',"data/#{name}/pages/blog-post.yml"
      template 'lib/templates/pages/latest-posts.yml',"data/#{name}/pages/latest-posts.yml"
    end
    copy_file 'lib/templates/public/favicon.png', 'public/favicon.png'

    template 'lib/templates/schemaless/footer.yml',"data/#{name}/schemaless/footer.yml"
    template 'lib/templates/schemaless/navigation.yml',"data/#{name}/schemaless/navigation.yml"
    template 'lib/templates/schemaless/social-toolbar.yml',"data/#{name}/schemaless/social-toolbar.yml"

    template 'lib/templates/pages/default.yml',"data/#{name}/pages/default.yml"
    template 'lib/templates/pages/home.yml',"data/#{name}/pages/home.yml"
    template 'lib/templates/pages/about.md',"data/#{name}/pages/about.md"
    template 'lib/templates/pages/contact-us.md',"data/#{name}/pages/contact-us.md"

    template 'lib/templates/single-app-config.ru', 'config.ru'
    template 'lib/templates/Gemfile', 'Gemfile'
    template 'lib/templates/Procfile', 'Procfile'

    if configs[:blog]
      while yes?('Would you like to add blog post?:', :green)
        post(configs[:name])
      end
    end
  end

  desc 'post <application-name>', 'create new post for given application name'
  def post(name)
    configs[:name] = name
    configs[:title] = ask('Title for the new post? (20 to 30 char) :', :green)
    sanitize_title = configs[:title].gsub(' ','-').gsub('\'','').gsub(',','').downcase   #TODO: proper sanitization
    configs[:sanitize_title] = sanitize_title
    tags = ask('Tags as comma separated list?  :', :green)
    configs[:tags] = tags.split(',')

    template 'lib/templates/blog/my-first-post.md',"data/#{name}/posts/#{sanitize_title}.md"
    copy_file 'lib/templates/public/blog/posts/images/my-first-post.png',"public/#{name}/posts/images/#{sanitize_title}.png"
    copy_file 'lib/templates/public/blog/posts/images/my-first-post/1-post-image.png',"public/#{name}/posts/images/#{sanitize_title}/1-post-image.png"
  end

  desc 'delete <name>', 'delete application'
  def delete(name)
    if yes?("Are you sure you would like to delete #{name}?")
      remove_dir "data/#{name}"
      remove_dir "public/#{name}"
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
  method_option :verbose, type: :boolean, aliases: '-v', default: false, desc: 'Show verbose information during seed (debug level logs).'
  def seed(name)
    clean(name) if options.clean?
    ENV['verbose'] = options.verbose?.to_s
    Dir.glob("data/#{name}/**/*.{json,md,yml}").each do |file|
      unless file.include?('ref_files') || file.include?('_config.yml')
        begin
          SoupCMS::CLI::Model::Base.create_model(File.new(file))
        rescue => e
          say "Error importing file... #{file}", :red
          say "#{e.backtrace.first}: #{e.message} (#{e.class})", :red
          say "#{e.backtrace.drop(1).map{|s| s }.join("\n")}", :red
        end
      end
    end
  end

  def self.source_root
    File.join(File.dirname(__FILE__), '../..')
  end


end

