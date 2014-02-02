module SoupCMS
  module CLI
    module Model

      class Chapter < SoupCMS::CLI::Model::Markdown

        def release
          file.path.split('/')[3]
        end

        def doc_name
          document_name = super
          document_name.match('^[\d]-').post_match
        end

        def chapter_number
          File.basename(file).match('^[\d]')[0].to_i
        end

        def old_doc
          @old_doc ||= (coll.find({'doc_id' => doc['doc_id'], 'release' => doc['release'], 'latest' => true}).to_a[0] || {})
        end

        def update_old_doc
          coll.update({'_id' => old_doc['_id'], 'release' => old_doc['release']}, {'$set' => {'latest' => false}}) unless old_doc.empty?
        end


        def build
          doc['release'] = release
          super
          doc['chapter_number'] = chapter_number
          build_chapter_links
        end

        def build_chapter_links
          chapters = Dir.glob(File.join(File.dirname(file), '/*.{json,md,yml}')).to_a
          index = chapters.index(file.path)
          if index > 0
            model = SoupCMS::CLI::Model::Chapter.new(File.new(chapters[index-1]))
            doc['prev_chapter'] = {'label' => model.title, 'link' => {'model_name' => 'chapters', 'match' => {'slug' => model.slug}}}
          end
          if index < (chapters.size-1)
            model = SoupCMS::CLI::Model::Chapter.new(File.new(chapters[index+1]))
            doc['next_chapter'] = {'label' => model.title, 'link' => {'model_name' => 'chapters', 'match' => {'slug' => model.slug}}}
          end
        end


      end


    end
  end
end
