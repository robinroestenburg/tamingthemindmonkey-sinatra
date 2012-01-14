require 'sinatra/base'

module Sinatra

  module Markdown

    class HTMLwithPygments < Redcarpet::Render::HTML
      def block_code(code, language)
        Pygments.highlight(code, :lexer => language)
      end
    end

    def markdown(text)
      options  = { :autolink => true, :space_after_headers => true, :fenced_code_blocks => true }
      markdown = Redcarpet::Markdown.new(HTMLwithPygments, options)
      markdown.render(text)
    rescue
      'Error occurred during Markdown rendering.'
    end
  end

  helpers Markdown
end
