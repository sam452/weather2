root_dir = File.dirname(__FILE__)

#set :environment, ENV['RACK_ENV'].to_sym
#set :root,        root_dir
#set :app_file,    File.join(root_dir, 'app.rb')
#disable :run
require 'rubygems'
require 'sinatra'
require File.expand_path '../app.rb', __FILE__

run Sinatra::Application
