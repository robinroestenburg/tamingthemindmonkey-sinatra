class TamingTheMindMonkey < Sinatra::Application

  get '/' do
    post = Post.create(
      :title      => "My first DataMapper post",
      :body       => "A lot of text ...",
      :created_at => Time.now
    )

    "Hello world, it's #{Post.count} at the server!"
  end

end
