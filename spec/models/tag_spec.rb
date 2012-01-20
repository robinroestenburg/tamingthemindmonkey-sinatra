require_relative '../../models/tag'
require_relative '../../models/post'

describe Tag do

  let(:foo) { double(:tags => ['Foo']) }
  let(:bar) { double(:tags => ['Bar']) }

  it 'has a list of posts using this tag' do
    Post.stub(:all_posts).and_return([foo, bar])

    Tag.posts_for('Bar').should == [bar]
  end

  describe '#all' do

    subject { Tag.all }

    it 'returns a list of all tags' do
      Post.stub(:all_posts).and_return([foo, bar])
      subject.should == ['Foo', 'Bar']
    end

    it 'does not return duplicate tags' do
      Post.stub(:all_posts).and_return([foo, foo, bar])
      subject.should == ['Foo', 'Bar']
    end
  end
end
