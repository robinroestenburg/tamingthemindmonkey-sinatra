require_relative '../../presenters/posts_presenter'
require 'ostruct'

describe PostsPresenter do

  describe '#grouped_by_month_and_year' do

    let(:collection) do
      [OpenStruct.new(published_at: Time.new(2011, 1, 1)),
       OpenStruct.new(published_at: Time.new(2011, 1, 1)),
       OpenStruct.new(published_at: Time.new(2011, 6, 1)),
       OpenStruct.new(published_at: Time.new(2012, 8, 1))]
    end

    subject { PostsPresenter.new(collection).grouped_by_year_and_month }

    it 'groups items by year and month' do
      subject[2011][1].count.should == 2
      subject[2011][6].count.should == 1
      subject[2012][8].count.should == 1
    end

  end

end
