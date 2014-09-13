module SoupCMS
  module CLI
    module Model

      class MobileImage < SoupCMS::CLI::Model::Image

        def doc_id
          super.gsub('.mobile.','.')
        end

        def image_for
          'mobile'
        end


      end


    end
  end
end
