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
  method_option :skip_dir, type: :boolean, aliases: '-t', default: false, desc: 'Skip top level directory for application.'
  method_option :generate, type: :boolean, aliases: '-g', default: false, desc: 'Generate NEW soupcms application. Default is false.'
  def new(name)
    configs[:name] = name
    configs[:display_name] = ask('Short display application name? (10 to 15 char) :', :green)
    configs[:description] = ask('Long application description? (30 to 40 char) :', :green)

    if yes?('Would you like to host your website public on platform like Heroku? (y/n):', :cyan)
      configs[:site_name] = ask('Provide the hostname for your website (e.g. http://myblog.herokuapp.com OR http://www.myblog.com) :', :green)
    end

    configs[:blog] = yes?('Blog support? (y/n):', :cyan)
    if configs[:blog]
      say('Choose blog layout? (y/n):',:green)
      blog_layouts = [[1, 'full-width'], [2, 'right-sidebar'], [3, 'left-sidebar']]
      print_table blog_layouts
      layout = ask('choose from', :green, :limited_to => %w(1 2 3))
      configs[:blog_layout] = blog_layouts[layout.to_i - 1][1]
    end

    top_dir = options.skip_dir? ? '.' : name
    data_folder = "#{top_dir}/data/#{name}"
    if configs[:blog]
      template 'lib/templates/pages/post.yml',"#{data_folder}/pages/post.yml"
      template 'lib/templates/pages/posts.yml',"#{data_folder}/pages/posts.yml"
    end
    copy_file 'lib/templates/public/favicon.png', "#{top_dir}/public/favicon.png"
    copy_file 'lib/templates/public/favicon.ico', "#{top_dir}/public/favicon.ico"
    copy_file 'lib/templates/public/common/stylesheets/_custom-variables.scss', "#{top_dir}/public/common/stylesheets/_custom-variables.scss"

    template 'lib/templates/schemaless/footer.yml',"#{data_folder}/schemaless/footer.yml"
    template 'lib/templates/schemaless/navigation.yml',"#{data_folder}/schemaless/navigation.yml"
    template 'lib/templates/schemaless/author.yml',"#{data_folder}/schemaless/author.yml"

    template 'lib/templates/modules/author.yml',"#{data_folder}/modules/author.yml"
    template 'lib/templates/modules/navigation.yml',"#{data_folder}/modules/navigation.yml"
    template 'lib/templates/modules/projects.yml',"#{data_folder}/modules/projects.yml"
    template 'lib/templates/modules/tag-cloud.yml',"#{data_folder}/modules/tag-cloud.yml"
    template 'lib/templates/modules/share-this.yml',"#{data_folder}/modules/share-this.yml"

    template 'lib/templates/pages/default.yml',"#{data_folder}/pages/default.yml"
    template 'lib/templates/pages/home.yml',"#{data_folder}/pages/home.yml"
    template 'lib/templates/pages/about.md',"#{data_folder}/pages/about.md"

    template 'lib/templates/Gemfile', "#{top_dir}/Gemfile"
    template 'lib/templates/Procfile', "#{top_dir}/Procfile"
    template 'lib/templates/.gitignore', "#{top_dir}/.gitignore"

    template 'lib/templates/single-app-config.ru', "#{top_dir}/config.ru"

    if configs[:blog]
      while yes?('Would you like to add blog post? (y/n):', :cyan)
        post(configs[:name], top_dir)
      end
    end

    create_file "#{top_dir}/data/#{name}/_config.yml", YAML.dump(JSON.parse(configs.to_json))
  end

  desc 'post <name>', 'create new post for given application name'
  def post(name, top_dir = '.')
    configs[:name] = name
    configs[:title] = ask('Title for the new post? (20 to 30 char) :', :green)
    sanitize_title = sanatize(configs[:title])
    configs[:sanitize_title] = sanitize_title
    tags = ask('Tags as comma separated list:', :green)
    configs[:tags] = tags.split(',')

    template 'lib/templates/blog/my-first-post.md',"#{top_dir}/data/#{name}/posts/#{sanitize_title}.md"
    copy_file 'lib/templates/public/blog/posts/images/my-first-post.png',"#{top_dir}/public/#{name}/posts/images/#{sanitize_title}.png"
    copy_file 'lib/templates/public/blog/posts/images/my-first-post/1-post-image.png',"#{top_dir}/public/#{name}/posts/images/#{sanitize_title}/1-post-image.png"
  end

  desc 'delete <name>', 'delete application'
  def delete(name)
    if yes?("Are you sure you would like to delete #{name}? (y/n):")
      remove_dir "data/#{name}"
      remove_dir "public/#{name}"
      remove_file 'Procfile'
      remove_file 'config.ru'
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

  private
  def sanatize(value)
    value.gsub(/\W/, '-').gsub('--','-').downcase
  end


end

