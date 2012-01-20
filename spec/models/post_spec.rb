require_relative '../../models/post'
require 'preamble'

describe Post do

  describe '#all_posts' do

    let(:foo) { double(:filename => 'posts/Foo') }
    let(:bar) { double(:filename => 'posts/Bar') }
    let(:baz) { double(:filename => 'posts/Baz') }

    before do
      Dir.stub(:new).and_return(['.', '..', 'Baz', 'Foo', 'Bar'])
      Post.stub(:parse_file).and_return(['Tags', 'Quux'])
    end

    subject { Post.all_posts }

    it 'returns all posts' do
      subject.size.should == 3
    end

    it 'returns the posts in reverse order' do
      subject.should == [bar, foo, baz]
    end
  end

  describe '#tags' do

    it { should respond_to(:tags) }

    it 'returns an empty list for a post without tags' do
      subject.tags.should == []
    end
  end

  describe '#parse_tag_list' do

    it 'returns an empty list when no tags are present' do
      Post.parse_tag_list(nil).should == []
      Post.parse_tag_list('').should == []
    end

    it 'returns a list of tags' do
      Post.parse_tag_list('Foo Bar').should == ['Foo', 'Bar']
    end

    it 'does not return duplicate tags' do
      Post.parse_tag_list('Foo Foo Bar').should == ['Foo', 'Bar']
    end
  end

  context 'with next posts' do

    let(:foo) { double }

    before do
      Post.stub(:all_posts).and_return([foo, subject])
      Post.any_instance.stub(:post_position).and_return(1)
    end

    it 'has a next post' do
      subject.has_next?.should be_true
    end

    it 'returns the next post' do
      subject.next_post.should == foo
    end
  end

  context 'without next posts' do

    before do
      Post.stub(:all_posts).and_return([subject])
      Post.any_instance.stub(:post_position).and_return(0)
    end

    it 'has no next post' do
      subject.has_next?.should_not be_true
    end

    it 'raises an error when accessing the next post' do
      subject.next_post.should be_nil
    end
  end

  context 'with previous post' do

    let(:foo) { double }
    let(:bar) { double }

    before do
      Post.stub(:all_posts).and_return([foo, subject, bar])
      Post.any_instance.stub(:post_position).and_return(1)
    end

    it 'has a previous post' do
      subject.has_previous?.should be_true
    end

    it 'returns the previous post' do
      subject.previous_post.should == bar
    end
  end

  context 'without previous post' do

    before do
      Post.stub(:all_posts).and_return([subject])
      Post.any_instance.stub(:post_position).and_return(0)
    end

    it 'has no previous post' do
      subject.has_previous?.should_not be_true
    end

    it 'raises an error when accessing the previous post' do
      subject.next_post.should be_nil
    end
  end
end
