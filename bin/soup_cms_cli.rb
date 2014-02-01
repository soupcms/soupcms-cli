require 'thor'

class SoupCMSCLI < Thor

  desc 'new <name>', 'create new application'
  def new(name)
    puts "#{name}"
  end

end


SoupCMSCLI.start