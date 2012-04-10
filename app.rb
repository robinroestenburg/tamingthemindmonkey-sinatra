require 'rubygems'
require 'bundler/setup'
require 'redcarpet'
require 'preamble'
require 'pygments'
require 'haml'

require 'sinatra'
require "sinatra/reloader" if development?

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
require_relative 'presenters/init'
require_relative 'routes/init'
