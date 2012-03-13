require 'xml-sitemap'

class TamingTheMindMonkey < Sinatra::Application

  get '/' do
    @posts = Post.grouped_by_year_and_month
    haml :index
  end

  get '/sitemap.xml' do
    map = XmlSitemap::Map.new('tamingthemindmonkey.com') do |m|
      m.add(:url => '/')

      Post.all_posts.each do |post|
        m.add(:url => post.permalink)
      end

      m.add(:url => '/tags')

      Tag.all.each do |tag|
        m.add(:url => "/tag/#{tag}")
      end
    end

    headers['Content-Type'] = 'text/xml'
    map.render
  end
end
