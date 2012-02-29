class TamingTheMindMonkey < Sinatra::Application

  get '/tag/*' do |tag|
    @tag   = tag
    @posts = Tag.posts_for(tag)
    @title = "Taming the Mind Monkey - Tag: #{tag}"
    haml :tag
  end

  get '/tags' do
    @tags = Tag.all
    @title = "Taming the Mind Monkey - Tags"
    haml :tags
  end

end
