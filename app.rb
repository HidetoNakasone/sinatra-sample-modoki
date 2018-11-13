
require "sinatra"
require "sinatra/reloader"

require "json"

json_path = File.dirname(__FILE__) + '/data/data.json'


def time_con(time_info)
  if time_info > Time.now - 60
    # 1分 以内
    "#{(Time.now - time_info).floor}秒前"
  elsif time_info > Time.now - (60*60)
    # 1時間 以内
    "#{((Time.now - time_info)/(60)).floor}分前"
  elsif time_info > Time.now - (24*60*60)
    # 24時間 以内
    "#{((Time.now - time_info)/(60*60)).floor}時間前"
  elsif time_info > Time.now - (30*24*60*60)
    # 1月 以内
    "#{((Time.now - time_info)/(24*60*60)).floor}日前"
  elsif time_info > Time.now - (365*24*60*60)
    # 1年 以内
    "#{((Time.now - time_info)/(30*24*60*60)).floor}ヶ月前"
  else
    # 1年 以上
    "#{((Time.now - time_info)/(365*24*60*60)).floor}年前"
  end
end



get '/' do

  open(json_path) do |io|
    @data = JSON.load(io)
  end

  @data.each do |row|
    row['up-time-info'] << time_con(Time.parse(row['up-time']))
  end

  erb :index
end

post '/save' do

  filename = params[:upimg][:filename]
  file = params[:upimg][:tempfile]
  File.open("./public/up-imgs/#{filename}", 'wb') do |f|
    f.write(file.read)
  end

  datum = {
    "up-time" => DateTime.now,
    "up-time-info" => "",
    "img-path" => params[:upimg][:filename]
  }

  data = []
  open(json_path) do |io|
    data = JSON.load(io)
  end

  data << datum

  open(json_path, 'w') do |io|
    JSON.dump(data, io)
  end


  redirect '/'
end
