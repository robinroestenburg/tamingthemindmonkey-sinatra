class TamingTheMindMonkey < Sinatra::Application

  get '/tag/*' do |tag|
    @tag   = tag
    @posts = Tag.posts_for(tag)
    haml :tag
  end

  get '/tags' do
    @tags = Tag.all

    haml :tags
  end

end
