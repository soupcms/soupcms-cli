require 'tilt'
require 'sprockets'

require 'soupcms/core'
require 'soupcms/api'

SoupCMS::Common::Strategy::Application::SingleApp.configure do |app|
  app.app_name = "<%= configs[:name] %>"
  app.display_name = "<%= configs[:display_name] %>"
  <%- if configs[:site_name] %>
  if ENV['RACK_ENV'] == 'production'
    app.soupcms_api_url = '<%= configs[:site_name] %>/api'
    app.app_base_url = '<%= configs[:site_name] %>/'
  else
    app.soupcms_api_url = 'http://localhost:9292/api'
    app.app_base_url = 'http://localhost:9292/'
  end
  <%- else %>
  app.soupcms_api_url = 'http://localhost:9292/api'
  app.app_base_url = 'http://localhost:9292/'
  <%- end %>
end

map '/api' do
  SoupCMSApi.configure do |config|
    config.application_strategy = SoupCMS::Common::Strategy::Application::SingleApp
    config.data_resolver.register(/content$/,SoupCMS::Api::Resolver::KramdownMarkdownResolver)
  end
  run SoupCMSApiRackApp.new
end

PUBLIC_DIR = File.join(File.dirname(__FILE__), 'public')
map '/assets' do
  sprockets = SoupCMSCore.config.sprockets
  sprockets.append_path PUBLIC_DIR
  sprockets.append_path SoupCMS::Core::Template::Manager::DEFAULT_TEMPLATE_DIR
  Sprockets::Helpers.configure do |config|
    config.environment = sprockets
    config.prefix = '/assets'
    config.public_path = nil
    config.digest = true
  end
  run sprockets
end

map '/' do
  SoupCMSCore.configure do |config|
    config.application_strategy = SoupCMS::Common::Strategy::Application::SingleApp
  end
  soup_cms_rack_app = SoupCMSRackApp.new
  soup_cms_rack_app.set_redirect('http://localhost:9292','http://localhost:9292/home')
  soup_cms_rack_app.set_redirect('http://localhost:9292/','http://localhost:9292/home')
  <%- if configs[:site_name] %>
  soup_cms_rack_app.set_redirect('<%= configs[:site_name] %>','<%= configs[:site_name] %>/home')
  soup_cms_rack_app.set_redirect('<%= configs[:site_name] %>/','<%= configs[:site_name] %>/home')
  <%- end %>
  run soup_cms_rack_app
end


