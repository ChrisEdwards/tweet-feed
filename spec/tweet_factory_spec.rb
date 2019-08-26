require "spec_helper"

describe "Create tweet" do

  it "should create a tweet with a populated id and no urls" do
    tweet = FactoryGirl.build(:tweet)
    tweet.id.should > 0
    tweet.urls.count.should == 0
  end

  it "should create a tweet with a populated id and a url" do
    tweet = FactoryGirl.build(:tweet_with_url)
    tweet.id.should > 0
    tweet.urls.count.should == 1
  end

end

describe "Create Url" do
  it "should create a url" do
    url = FactoryGirl.build(:url)
    url.url.length.should > 0
  end
end