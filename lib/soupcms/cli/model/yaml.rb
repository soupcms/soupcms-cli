module SoupCMS
  module CLI
    module Model

      class Yaml < SoupCMS::CLI::Model::Base

        def parse_file
          document_hash = YAML.load(file.read)
          SoupCMS::CLI::ResolveFileReference.new(File.dirname(file)).parse(document_hash)
        end


      end


    end
  end
end
