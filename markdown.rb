##
# MyAppIn (http://www.appin.cz)
# @author    Martin Lonsky (martin@lonsky.net, +420 736 645876)
# @link      http://www.myappin.cz
# @copyright Copyright (c) MyAppIn s.r.o. (http://www.myappin.cz)
# Date: 10. 5. 2016
# Time: 12:49

require 'pygmentize'
require 'redcarpet'
require 'optparse'

class Markdown
  class << self

    def options_parser
      @@options = {
          file: ''
      }
      OptionParser.new do |opts|
        opts.banner = 'Usage: markdown --file <filepath>'
        opts.on('--file FILEPATH', 'Set filepath') do |path|
          @@options[:file] = path
        end
      end
    end

    def render(args)
      options_parser.parse!(args)
      if !File.exists?(@@options[:file])
        STDOUT.write sprintf('File "%s" does not exist', @@options[:file])
        exit
      end
      file = File.open(@@options[:file], 'r')
      STDOUT.write markdown.render(file.read)
    end

    private
      def markdown
        @markdown ||= Redcarpet::Markdown.new(
            HTMLWithPygments,
            filter_styles: true,
            filter_html: true,
            fenced_code_blocks: true,
            autolink: true,
            space_after_headers: true
        )
      end
  end

  class HTMLWithPygments < Redcarpet::Render::HTML
    def block_code(code, language)
      language = language && language.split.first || "text"
      output = add_code_tags(
          Pygmentize.process(code, language, ['-O linenos=1']), language
      )
    end

    def add_code_tags(code, language)
      code = code.sub(/<pre>/,'<div class="lang">' + language + '</div><pre><code class="' + language + '">')
      code = code.sub(/<\/pre>/,'</code></pre>')
      code = code.sub(/<table class=\"highlighttable\">/, '<div class="highlight-wrap"><table class="highlighttable">')
      code = code.sub(/<\/table>/, '</table></div>')
    end
  end
end