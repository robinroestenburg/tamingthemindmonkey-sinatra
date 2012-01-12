require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db")

require_relative 'post'
