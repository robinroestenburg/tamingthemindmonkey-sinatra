class TamingTheMindMonkey < Sinatra::Application

  get '/' do
    @posts = Post.grouped_by_year_and_month
    haml :index
  end

end
