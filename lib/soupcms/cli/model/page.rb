module SoupCMS
  module CLI
    module Model

      class Page < SoupCMS::CLI::Model::Markdown

        def parse_file
          @attributes, @content = SoupCMS::CLI::FrontMatterParser.new.parse(file.read)
          {
              'areas' => [
                  {
                      'name' => 'body',
                      'modules' => [
                          {
                              'recipes' => [
                                  {
                                      'type' => 'inline',
                                      'data' => {
                                          'content' => {
                                              'type' => 'markdown',
                                              'flavor' => content_flavor,
                                              'value' => @content
                                          }
                                      },
                                      'return' => 'article'
                                  }
                              ],
                              'template' => {
                                  'type' => 'slim',
                                  'name' => 'bootstrap/article'
                              }
                          }
                      ]
                  }
              ]
          }
        end

        def title
          return doc['title'] if doc['title']

          data = doc['areas'][0]['modules'][0]['recipes'][0]['data']
          content_lines = data['content']['value'].lines
          doc_title = content_lines.first.chomp
          data['content']['value'] = content_lines[2] ? content_lines[2..-1].join("\n") : ''
          doc_title = doc_title.gsub('_', ' ').gsub('#', '').strip
          data['title'] = doc_title
          doc_title
        end

        def description
          return doc['description'] if doc['description']

          post_description = ''
          data = doc['areas'][0]['modules'][0]['recipes'][0]['data']
          content_lines = data['content']['value'].lines
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
