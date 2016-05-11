##
# MyAppIn (http://www.appin.cz)
# @author    Martin Lonsky (martin@lonsky.net, +420 736 645876)
# @link      http://www.myappin.cz
# @copyright Copyright (c) MyAppIn s.r.o. (http://www.myappin.cz)
# Date: 10. 5. 2016
# Time: 12:49

require 'redcarpet'
require 'optparse'
require "shellwords"

class Markdown
  class << self

    def options_parser
      @@options = {
          file: '',
      }
      OptionParser.new do |opts|
        opts.banner = 'Usage: markdown --file <path>'
        opts.on('--file path', 'Set path') do |path|
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
          escape_html: true,
          safe_links_only: false,
          fenced_code_blocks: true,
          autolink: true,
          space_after_headers: true,
          tables: true,
          lax_spacing: true,
          superscript: true,
          highlight: true,
          quote: true,
          footnotes: true,
          underline: true,
          strikethrough: true,
      )
    end
  end

  class HTMLWithPygments < Redcarpet::Render::Safe
    def block_code(code, language)
      language = language && language.split.first || "text"
      args = [
          '-O', 'linenos=table',
          '-O', 'linespans=line',
          '-O', 'startinline=1',
          '-O', "encoding=#{code.encoding}",
          '-l', "#{language.to_s}",
          '-f', 'html',
      ]
      output = add_code_tags(
          IO.popen("/usr/bin/pygmentize #{Shellwords.shelljoin args}", 'r+') do |io|
            io.write(code)
            io.close_write
            io.read
          end,
          language
      )
    end

    def add_code_tags(code, language)
      code = code.sub(/<pre>/, '<div class="lang">' + language + '</div><pre><code class="' + language + '">')
      code = code.sub(/<\/pre>/, '</code></pre>')
      code = code.sub(/<table class=\"highlighttable\">/, '<div class="highlight-wrap"><table class="highlighttable">')
      code = code.sub(/<\/table>/, '</table></div>')
    end

    def table(header, body)
      output = "<table class='table table-striped'><thead>#{header}</thead><tbody>#{body}</tbody></table>"
    end
  end
end