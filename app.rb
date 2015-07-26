require 'json'
require "sinatra"
require "data_mapper"
require 'dm-migrations'
require 'sinatra/flash'

enable :sessions
set :port,  4567

configure :development do
  DataMapper.setup(
    :default, "postgres://pi:{#ENV['PGPW']}@localhost/test"
  )
end

configure :production do
  DataMapper.setup(
    :default, 'postgres://postgres:123@localhost/sinatra_service'
  )
end


class Weather
  include DataMapper::Resource
  property :id,  Serial
  property :content, String
  property :temperature, String
  property :humidity, String
  property :completed_at, DateTime
  property :created_at, DateTime
end

DataMapper.finalize
Weather.auto_upgrade!

get "/records/?" do
  $records = Weather.all(:order => :created_at.desc)
  erb :"weather/index"
end


