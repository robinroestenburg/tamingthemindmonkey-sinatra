class PostsPresenter

  def initialize(collection) 
    @collection = collection
  end

  def grouped_by_year_and_month
    Hash[
      @collection.
        group_by { |post| post.published_at.year }.
        collect do |year, posts_by_year|
          [ year, posts_by_year.group_by { |post| post.published_at.month } ]
        end]
  end
end
