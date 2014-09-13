module SoupCMS
  module CLI
    module Model

      class TabletImage < SoupCMS::CLI::Model::Image

        def doc_id
          super.gsub('.tablet.','.')
        end

        def image_for
          'tablet'
        end

      end


    end
  end
end
