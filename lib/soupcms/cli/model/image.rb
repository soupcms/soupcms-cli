require 'digest/md5'
require 'cloudinary'

module SoupCMS
  module CLI
    module Model

      class Image < SoupCMS::CLI::Model::Base

        def image_public_name
          md5
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

          @doc = coll.find({'doc_id' => doc_id}).to_a[0] || {}
          timestamp = file.mtime.to_i
          @doc.merge!({
                          'source' => 'cloudinary',
                          'doc_id' => doc_id,
                          'locale' => 'en_US',
                          'publish_datetime' => timestamp,
                          'version' => timestamp,
                          'update_datetime' => timestamp,
                          'create_datetime' => timestamp,
                          'create_by' => 'seed',
                          'state' => 'published',
                          'latest' => true
                      })

          @doc[image_for] = upload
          @doc[image_for_md5] = md5
          @doc['_id'] ? coll.update({'_id' => @doc['_id']},@doc) : coll.insert(@doc)
          conn.close
        end


        def exists?
          coll.find({image_for_md5 => md5, 'doc_id' => doc_id}).count > 0
        end


        def upload
          @logger.info "Uploading image '#{doc_id}' to folder '#{app_name}'"
          return coll.find({image_for_md5 => md5}).to_a[0]['desktop'] if coll.find({image_for_md5 => md5}).count > 0

          @logger.info "Using cloudinary configs: #{ENV['CLOUDINARY_CLOUD_NAME']},#{ENV['CLOUDINARY_API_KEY']},#{ENV['CLOUDINARY_API_SECRET']}"
          Cloudinary.config do |config|
            config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
            config.api_key = ENV['CLOUDINARY_API_KEY']
            config.api_secret = ENV['CLOUDINARY_API_SECRET']
          end

          response = Cloudinary::Uploader.upload(@file, public_id: image_public_name)
          "v#{response['version']}/#{response['public_id']}.#{response['format']}"
        end


        def image_for
          'desktop'
        end

        def image_for_md5
          "#{image_for}MD5"
        end

      end


    end
  end
end
