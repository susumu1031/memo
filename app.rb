require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'pg'
require "erb"
include ERB::Util

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/memo' do
  connection = PG::connect(:host => "localhost", :user => "postgres", :dbname => "memoapp")
  begin
    @hash = connection.exec("SELECT * from memodata")
    erb :memo_top
  ensure
    connection.close
  end
end

get '/memo/new' do
  erb :memo_new
end

post '/memo_data' do
  @title = params[:title]
  @message = params[:message]
  @id = SecureRandom.uuid
  #@time = Time.now
  connection = PG::connect(:host => "localhost", :user => "postgres", :dbname => "memoapp")
  begin
    connection.exec( "insert into memodata (id, title, message) values ('#{@id}', '#{@title}', '#{@message}')")
  ensure
    connection.close
  end
  redirect to('/memo')
end

get '/memo_data/:id' do
  @id = params[:id]
  connection = PG::connect(:host => "localhost", :user => "postgres", :dbname => "memoapp")
  begin
    @result = connection.exec("SELECT title, message from memodata WHERE id = '#{@id}'")
    @hash = @result[0]
    erb :reconfirm
  ensure
    connection.close
  end
end

get '/memo_data/:id/edit' do
  @id = params[:id]
  connection = PG::connect(:host => "localhost", :user => "postgres", :dbname => "memoapp")
  begin
    @result = connection.exec("SELECT title, message from memodata WHERE id = '#{@id}'")
    @hash = @result[0]
    erb :edit
  ensure
    connection.close
  end
end

patch '/memo_data/:id' do
  @id = params[:id]
  @title = params[:title]
  @message = params[:message]
  @id = params[:id]
  connection = PG::connect(:host => "localhost", :user => "postgres", :dbname => "memoapp")
  begin
    result = connection.exec("UPDATE memodata set title = '#{@title}', message = '#{@message}' WHERE id = '#{@id}'")
  ensure
    connection.close
  end
  redirect to('memo')
end

delete '/memo_data/:id' do
  @id = params[:id]
  connection = PG::connect(:host => "localhost", :user => "postgres", :dbname => "memoapp")
  begin
    result = connection.exec("DELETE from memodata where id ='#{@id}'")
    #File.delete("memo_data/#{@id}.json")
  ensure
    connection.close
  end
  redirect to('/memo')
end