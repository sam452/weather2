require 'rubygems'
require 'json'
require "sinatra"
require "data_mapper"
require 'dm-migrations'
require 'sinatra/flash'
require 'json'
require 'will_paginate'
require 'will_paginate/data_mapper'

configure do
  enable :sessions
end

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
  # @records = Weather.all(:order => :created_at.desc)
  @records = Weather.paginate(:page => params[:page], :per_page => 30)
  erb :"index"
end

get "/records" do
  @records = Weather.all(:order => :created_at.desc)
  erb :"weather/index"
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
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

helpers do
  def to_fahrenheit(temp)
    temp.to_f * 9 / 5 + 32
  end
end
