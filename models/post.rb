class Post

  attr_accessor :title,
                :content,
                :author,
                :published_at,
                :tags,
                :filename

  POSTS_DIR = 'posts'

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
    self.filename == other.filename
  end

  def self.build(file_name)
    preamble, content = parse_file(file_name)

    post = Post.new
    post.filename     = file_name
    post.content      = content
    post.title        = preamble['title']
    post.author       = preamble['author']
    post.published_at = Date.parse(preamble['published_at']) if preamble['published_at']
    post.tags         = Post.parse_tag_list(preamble['tags'])
    post
  end

  def self.find_by_name(file_name)
    raise(ArgumentError, 'File does not exist!') unless File.file? file_name

    Post.build(file_name)
  end

  def self.find_most_recent
    all_posts[0..10]
  end

  def self.find_by_year(year)
    all_posts.
      select { |post| post.published_at.year == year }.
      group_by { |post| post.published_at.month }

  end

  def self.find_by_month(year, month)
    all_posts.select { |post| post.published_at.year == year && post.published_at.month == month }
  end

  def self.grouped_by_year_and_month
    Hash[
      all_posts.
        group_by { |post| post.published_at.year }.
        collect do |year, posts_by_year|
          [ year, posts_by_year.group_by { |post| post.published_at.month } ]
        end]
  end

  def self.all_posts
    Dir.new(POSTS_DIR).
      select { |file_name| file_name != '.' &&  file_name != '..' }.
      collect { |file_name| Post.build("#{POSTS_DIR}/#{file_name}") }.
      select { |post| post.published_at }.
      sort { |post, other| other.published_at <=> post.published_at }
  end

  def self.parse_tag_list(tags)
    return [] unless tags.is_a? String
    return [] if tags.empty?

    tags.split.uniq
  end

  private

  def self.parse_file(file_name)
    Preamble.load(file_name)
  end

  def post_position
    Post.all_posts.find_index(Post.build(filename))
  end

  def last_post?(index)
    (index - 1) < 0
  end

end
