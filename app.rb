require 'json'
require "sinatra"
require "data_mapper"
require 'dm-migrations'
require 'sinatra/flash'
require 'json'

enable :sessions

set :bind, '0.0.0.0'

configure :development do
  DataMapper.setup(
    :default, "postgres://pi:0@localhost/postgres"
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

get '/' do
  puts 'hell, jars'
end

get "/records" do
  @records = Weather.all(:order => :created_at.desc)
  erb :"weather/index"
end

post '/record' do
  body = JSON.parse request.body.read
    record = Weather.create(
    content: body['content'],
    temperature: body['temperature'],
    humidity: body['humidity']
    )
  status 201
  record.to_json
end


