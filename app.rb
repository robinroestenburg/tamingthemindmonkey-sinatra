require 'rubygems'
require 'bundler/setup'
require 'redcarpet'
require 'preamble'
require 'pygments'
require 'haml'

require 'sinatra'
require "sinatra/reloader" if development?


# class Post
#   include DataMapper::Resource
#
#   has n, :post_tags
#   has n, :tags, :through => :post_tags
#
#   property :id,           Serial
#   property :title,        String
#   property :body,         Text
#   property :created_at,   DateTime
#   property :published_at, DateTime
# end
#
# class Tag
#   include DataMapper::Resource
#
#   has n, :post_tags
#   has n, :posts,      :through => :post_tags
#
#   property :id,           Serial
#   property :name,         String
# end
#
# class PostTag
#   include DataMapper::Resource
#
#   property :id,         Serial
#   property :created_at, DateTime
#
#   belongs_to :tag
#   belongs_to :post
# end
#
# DataMapper.auto_migrate!
#
#
class TamingTheMindMonkey < Sinatra::Application
  # enable :sessions

  # configure :production do
  #   set :haml, { :ugly=>true }
  #   set :clean_trace, true
  #   set :css_files, :blob
  #   set :js_files,  :blob
  #   MinifyResources.minify_all
  # end

  # configure :development do
  #   set :css_files, MinifyResources::CSS_FILES
  #   set :js_files,  MinifyResources::JS_FILES
  # end

  # helpers do
  #   include Rack::Utils
  #   alias_method :h, :escape_html
  # end
end

require_relative 'helpers/init'
require_relative 'models/init'
require_relative 'routes/init'
