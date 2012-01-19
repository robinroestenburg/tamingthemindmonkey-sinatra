require 'models/tag'
require 'models/post'

describe Tag do

  let(:foo) { double(:tags => ['Foo']) }
  let(:bar) { double(:tags => ['Bar']) }

  it { should respond_to(:name) }

  it 'has a list of posts using this tag' do
    Post.stub(:all_posts).and_return([foo, bar])

    subject.name = 'Foo'
    subject.posts.should == [foo]
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
