require 'models/post'
require 'preamble'

describe Post do

  let(:foo) do
    post = Post.new
    post.filename = 'posts/Foo'
    post
  end

  let(:bar) do
    post = Post.new
    post.filename = 'posts/Bar'
    post
  end

  let(:baz) do
    post = Post.new
    post.filename = 'posts/Baz'
    post
  end

  before do
    Dir.stub(:new).and_return(['.', '..', 'Baz', 'Foo', 'Bar'])
    Post.stub(:parse_file).and_return(['Baz', 'Quux'])
  end

  describe '#all_posts' do

    subject { Post.all_posts }

    it 'returns two posts' do
      subject.size.should == 3
    end

    it 'returns the posts in reverse order' do
      subject.should == [bar, foo, baz]
    end
  end

  describe '#next_post' do

    subject { foo.next_post }

    context 'has next posts' do

      it 'returns the next post' do
        subject.should == bar
      end

    end

    context 'has no next posts' do

      before do
        Dir.stub(:new).and_return(['.', '..', 'Foo'])
      end

      it 'raises an error' do
        expect { subject }.to raise_error(IndexError)
      end

    end
  end

  describe '#previous_post' do

    subject { foo.previous_post }

    context 'has previous post' do

      it 'returns the previous post' do
        subject.should == baz
      end

    end

    context 'has no previous post' do

      before do
        Post.stub(:all_posts).and_return([foo])
      end

      it 'raises an error' do
        expect { subject }.to raise_error(IndexError)
      end

    end
  end

  describe '#has_previous?' do

  end

  describe '#has_next?' do

  end
end
