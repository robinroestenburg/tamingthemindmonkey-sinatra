class Post

  attr_accessor :title,
                :content,
                :author,
                :published_at,
                :tags,
                :filename


  def permalink
    match_data = filename.match(/posts\/(\d+)-(\d+)-(\d+)-(.+)\.markdown/)
    "#{match_data[1]}/#{match_data[2]}/#{match_data[3]}/#{match_data[4]}"
  end

  def self.build(file_name)
    preamble, content = parse_file(file_name)

    post = Post.new
    post.filename     = file_name
    post.content      = content
    post.title        = preamble['title']
    post.author       = preamble['author']
    post.published_at = preamble['published_at']
    post.tags         = preamble['tags']
    post
  end

  def self.find_by_name(file_name)
    raise(ArgumentError, 'File does not exist!') unless File.file? file_name

    Post.build(file_name)
  end

  def self.find_most_recent
    all_posts_on_disk.
      collect { |file_name| Post.build("posts/#{file_name}") }.
      reverse[0..10]
  end

  private

  def self.all_posts_on_disk
    Dir.new('posts').select { |file_name| file_name != '.' &&  file_name != '..' }
  end

  def self.parse_file(file_name)
    Preamble.load(file_name)
  end

end
