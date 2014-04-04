module SoupCMS
  module CLI
    module Model

      class Markdown < SoupCMS::CLI::Model::Base

        def content_flavor;
          File.basename(file).split('.').size > 2 ? File.basename(file).split('.')[1] : 'kramdown'
        end

        def parse_file
          @attributes, @content = SoupCMS::CLI::FrontMatterParser.new.parse(file.read)
          doc = {'content' => {'type' => 'markdown', 'flavor' => content_flavor, 'value' => @content}}
          doc.merge @attributes
        end

        def build
          super
          doc['title'] = title unless doc['title']
          doc['description'] = description unless doc['description']
        end

        def title
          content_lines = doc['content']['value'].lines
          doc_title = content_lines.first.chomp
          doc['content']['value'] = content_lines[2] ? content_lines[2..-1].join("\n") : ''
          doc_title.gsub('_', ' ').gsub('#', '').strip
        end

        def description
          post_description = ''
          content_lines = doc['content']['value'].lines
          index = 0
          while post_description.length < 300 && content_lines[index] do
            post_description.concat(content_lines[index].chomp.gsub(/\A[\d_\W]+|[\d_\W]+\Z/, ''))
            index += 1
          end
          post_description + '...'
        end

      end

    end
  end
end
