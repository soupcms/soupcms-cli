require 'thor'
require 'yaml'
require 'json'

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

    create_file "seed/#{name}/config.yml", YAML.dump(JSON.parse(configs.to_json))
    template 'lib/templates/my_first_post.tt',"seed/#{name}/posts/my_first_post.md"

  end

  def self.source_root
    File.join(File.dirname(__FILE__), '../..')
  end


end

