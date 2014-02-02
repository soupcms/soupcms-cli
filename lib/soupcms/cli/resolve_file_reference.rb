module SoupCMS
  module CLI


    class ResolveFileReference

      def initialize(path)
        @path = path
      end

      def parse(document)
        if document.kind_of?(Array)
          document.collect { |doc| parse_for_file(doc) }
        elsif document.kind_of?(Hash)
          parse_for_file(document)
        end
      end

      def parse_for_file(document)
        document.each do |key, value|
          if value.kind_of?(Array)
            document[key] = value.collect { |item| item.kind_of?(Hash) ? parse_for_file(item) : item }
          elsif value.kind_of?(Hash)
            document[key] = parse_for_file(value)
          elsif value.kind_of?(String) && value.match(/^\$file:/)
            document[key] = File.read(File.join(@path, 'ref_files', value.match(/\$file:([\w\.\-]*)/).captures[0]))
          end
        end
        @document = document
      end

    end

  end
end
