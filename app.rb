require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/memo' do
  memos = Dir.glob("memo_data/*")
  @hash = memos.map {|x| JSON.load(File.read(x))}
  erb :memo_top
end

get '/memo/new' do
  erb :memo_new
end

post '/memo_data' do
  @title = params[:title]
  @message = params[:message]
  @id = params[:id]
  @time = Time.now
  hash = { "id" => SecureRandom.uuid, "title" => @title, "message" => h(@message), "time" => @time }
  File.open("memo_data/#{hash["id"]}.json", "w") do |file|
    JSON.dump(hash, file)
  end
  redirect to('/memo')
end

get '/memo_data/:id' do
  @id = params[:id]
  File.open("memo_data/#{@id}.json") do |file|
    @hash = JSON.load(file)
  end
  erb :reconfirm
end

get '/memo_data/:id/edit' do
  @id = params[:id]
  File.open("memo_data/#{@id}.json") do |file|
   @hash = JSON.load(file)
  end
  erb :edit
end

patch '/memo_data/:id' do
  @id = params[:id]
  @title = params[:title]
  @message = params[:message]
  @time = Time.now
  hash = { "id" => @id, "title" => @title, "message" => h(@message), "time" => @time }
  File.open("memo_data/#{@id}.json", "w") do |file|
    JSON.dump(hash, file)
  end
  redirect to('memo')
end

delete '/memo_data/:id' do
  @id = params[:id]
  File.delete("memo_data/#{@id}.json")
  redirect to('/memo')
end
