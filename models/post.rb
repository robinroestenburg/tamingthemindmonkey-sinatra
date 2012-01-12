class Post

  attr_accessor :title, :content, :author, :published_at, :tags

  def self.build(preamble, content)
    post = Post.new
    post.content      = content
    post.title        = preamble['title']
    post.author       = preamble['author']
    post.published_at = preamble['published_at']
    post.tags         = preamble['tags']
    post
  end

  def self.find_by_name(file_name)
    puts file_name
    puts File.file? file_name
    raise(ArgumentError, 'File does not exist!') unless File.file? file_name

    puts file_name
    file = Preamble.load(file_name)

    Post.build(file[0], file[1])
  end
end
