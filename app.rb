require 'rubygems'
require 'json'
require "sinatra"
require "data_mapper"
require 'dm-migrations'
require 'sinatra/flash'
require 'json'
require 'will_paginate'
require 'will_paginate/data_mapper'
require 'time'
require 'date'

configure do
  enable :sessions
end

set :bind, '0.0.0.0'

configure :development do
  DataMapper.setup(
    :default, "postgres://wanzie@localhost/weathers"
  )
end

configure :production do
  DataMapper.setup(
    :default, 'postgres://wanzie@localhost/weathers'
  )
end


class Weather
  include DataMapper::Resource
  property :id,  Serial
  property :outsidetemperature, String
  property :outsidehumidity, String
  property :totalrain, String
  property :currentwinddirection, String
  property :currentwindspeed, String
  property :currentwindgust, String
  property :bmp180temperature, String
  property :bmp180pressure, String
  property :bmp180altitude, String
  property :bmp180sealevel, String
  property :timestamp, DateTime
end

DataMapper.finalize
Weather.auto_upgrade!

get '/' do
   @records = Weather.all(:limit => 100, :order => :timestamp.desc)
  
  #@records = Weather.all(:order => :created_at.desc).paginate(:page => params[:page], :per_page => 30)
  erb :"index"
end

get "/records" do
  @records = Weather.all(:order => :timestamp.desc)
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
    currentwindspeed: body['currentWindSpeed'],
    outsidetemperature: body['outsideTemperature'],
    outsidehumidity: body['outsideHumidity'],
    totalrain: body['totalRain'],
    currentwinddirection: body['currentwinddirection'],
    currentwindgust: body['currentWindGust'],
    bmp180temperature: body['bmp180Temperature'],
    bmp180pressure: body['bmp180Pressure'],
    bmp180altitude: body['bmp180Altitude']
    )
  status 201
  record.to_json
end

helpers do
  def to_fahrenheit(temp)
    temp.to_f * 9 / 5 + 32.round(2)
  end

  def to_central(time)
    string_time = Time.parse(time.to_s)
    offset = -1
    string_time + offset * 3600
  end
end
