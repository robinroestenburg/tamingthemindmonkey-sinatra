class Post

  attr_accessor :title,
                :content,
                :author,
                :published_at,
                :tags,
                :filename

  POSTS_DIR = 'posts'

  class << self

    def all_posts
      @@all_posts ||=
        Dir.new(POSTS_DIR).
          select { |file_name| file_name != '.' &&  file_name != '..' }.
          collect { |file_name| build("#{POSTS_DIR}/#{file_name}") }.
          select { |post| post.published_at }.
          sort { |post, other| other.published_at <=> post.published_at }
    end


    def build(file_name)
      preamble, content = parse_file(file_name)

      post              = new
      post.filename     = file_name
      post.content      = content
      post.title        = preamble['title']
      post.author       = preamble['author']
      post.published_at = Date.parse(preamble['published_at']) if preamble['published_at']
      post.tags         = parse_tag_list(preamble['tags'])
      post
    end

    def find_by_name(file_name)
      raise(ArgumentError, 'File does not exist!') unless File.file? file_name

      build(file_name)
    end

    def find_by_year(year)
      grouped_by_year_and_month[year]
    end

    def find_by_month(year, month)
      grouped_by_year_and_month[year][month]
    end

    def grouped_by_year_and_month
      Hash[
        all_posts.
          group_by { |post| post.published_at.year }.
          collect do |year, posts_by_year|
            [ year, posts_by_year.group_by { |post| post.published_at.month } ]
          end]
    end

    def parse_tag_list(tags)
      return [] unless tags.is_a? String
      return [] if tags.empty?

      tags.split.uniq
    end

    private

    def parse_file(file_name)
      Preamble.load(file_name)
    end
  end

  def initialize
    @tags = []
  end

  def truncated_title(length)
    if title.size < length
      title
    else
      if title[length] == ' '
        title[0..length-1] + '...'
      else
        title[0..length] + '...'
      end
    end
  end

  def permalink
    match_data = filename.match(/#{POSTS_DIR}\/(\d+)-(\d+)-(\d+)-(.+)\.markdown/)
    "#{match_data[1]}/#{match_data[2]}/#{match_data[3]}/#{match_data[4]}"
  end

  def has_next?
    next_post
  end

  def next_post
    index = post_position
    Post.all_posts.to_a.fetch(index - 1) unless last_post? index
  rescue IndexError
    false
  end

  def has_previous?
    previous_post
  end

  def previous_post
    index = post_position
    Post.all_posts.to_a.fetch(index + 1)
  rescue IndexError
    false
  end

  def ==(other)
    filename == other.filename
  end

  private

  def post_position
    Post.all_posts.find_index(Post.build(filename))
  end

  def last_post?(index)
    (index - 1) < 0
  end

end
