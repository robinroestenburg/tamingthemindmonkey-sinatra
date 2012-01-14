class TamingTheMindMonkey < Sinatra::Application

  get '/' do
    @posts = Post.find_most_recent
    haml :index
  end

end
