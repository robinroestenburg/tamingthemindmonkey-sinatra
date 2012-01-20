class Tag

  def self.posts_for(name)
    Post.all_posts.select { |post| post.tags.include? name }
  end

  def self.all
    Post.all_posts.map(&:tags).flatten.uniq
  end
end
