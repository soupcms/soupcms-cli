require 'yaml'

module SoupCMS
  module CLI

    class FrontMatterParser

      def parse(string)
        return {}, string if string.lines[0] && string.lines[0].chomp.strip != '---'
        res = [{}, '']
        res[1] = string.lstrip.gsub(/---(.*)---/m) do |match|
          front_matter = $~.captures.first.strip
          res[0] = YAML.load(front_matter)
          ''
        end.strip
        return res[0], res[1]
      end

    end

  end
end