class TamingTheMindMonkey < Sinatra::Application

  get '/*/*/*/*' do |year, month, day, title|
    begin
      file_name = "posts/#{year}-#{month}-#{day}-#{title}.markdown"

      @post = Post.find_by_name(file_name)
      @title = "Taming the Mind Monkey - #{@post.title}"
      haml :post

    rescue
      pass # Show the month overview.
    end
  end

  get %r{/([\d]+)/([\d]+)} do |year, month|
    begin
      month   = month.to_i
      year    = year.to_i

      @month  = Date.new(year, month)
      @posts  = Post.find_by_month(year, month)
      @title  = "Taming the Mind Monkey - Archive #{year}-#{month}"
      haml :month
    rescue
      pass # Show the year overview.
    end
  end

  get %r{/([\d]+)} do |year|
    @year   = year.to_i
    @months  = Post.find_by_year(@year)
    @title  = "Taming the Mind Monkey - Archive #{year}"
    haml :year
  end

end
