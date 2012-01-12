class TamingTheMindMonkey < Sinatra::Application

  get '/*/*/*/*' do |year, month, day, title|
    # begin
      file_name = "posts/#{year}-#{month}-#{day}-#{title}.markdown"

      @post = Post.find_by_name(file_name)
      haml :post
    # rescue
    #   pass # Show the month overview.
    # end
  end

  get %r{/([\d]+)/([\d]+)} do |year, month|
    "Month overview not implemented yet."
  end

  get %r{/([\d]+)} do |year|
    "Year overview not implemented yet."
  end
end
