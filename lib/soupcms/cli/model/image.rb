require 'digest/md5'
require 'cloudinary'

module SoupCMS
  module CLI
    module Model

      class Image < SoupCMS::CLI::Model::Base

        def image_public_name
          "#{doc_name}-#{md5}"
        end

        def md5
          @md5 ||= Digest::MD5.hexdigest(File.read(@file))
        end

        def doc_id
          file.path.split('/').drop(2).join('/')
        end

        def model;
          'images'
        end

        def create
          return if exists?

          timestamp = file.mtime.to_i
          @doc = {
              'source' => 'cloudinary',
              'doc_id' => doc_id,
              'md5' => md5,
              'locale' => 'en_US',
              'publish_datetime' => timestamp,
              'version' => timestamp,
              'update_datetime' => timestamp,
              'create_datetime' => timestamp,
              'create_by' => 'seed',
              'state' => 'published',
              'latest' => true
          }

          response = upload
          @doc['desktop'] = "v#{response['version']}/#{response['public_id']}.#{response['format']}"
          old_image = coll.find({'doc_id' => doc_id}).to_a[0]
          coll.insert(@doc)
          coll.remove(old_image) if old_image
          conn.close
        end

        def exists?
          coll.find({'md5' => md5, 'doc_id' => doc_id}).count > 0
        end

        def upload
          @logger.info "Uploading image '#{file.path}'"
          return {'version' => '12345', 'public_id' => 'sunit', 'format' => type}

          Cloudinary.config do |config|
          end
          Cloudinary::Uploader.upload(@file, :public_id => image_public_name)
        end


      end


    end
  end
end
