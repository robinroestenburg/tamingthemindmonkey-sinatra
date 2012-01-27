class TamingTheMindMonkey < Sinatra::Application

  get '/*/*/*/*' do |year, month, day, title|
    begin
      file_name = "posts/#{year}-#{month}-#{day}-#{title}.markdown"

      @post = Post.find_by_name(file_name)
      haml :post

    rescue
      pass # Show the month overview.
    end
  end

  get %r{/([\d]+)/([\d]+)} do |year, month|
    begin
      @year   = year
      @month  = month
      @posts  = Post.find_by_month(@year, @month)
      haml :month
    rescue
      pass # Show the year overview.
    end
  end

  get %r{/([\d]+)} do |year|
    @year   = year
    @months  = Post.find_by_year(@year)
    haml :year
  end

end
