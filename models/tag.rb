class Tag
  attr_accessor :name

  def initialize
    @name = 'Foo'
  end

  def posts
    Post.all_posts.select { |post| post.tags.include? name }
  end

  def self.all
    Post.all_posts.map(&:tags).flatten.uniq
  end
end
