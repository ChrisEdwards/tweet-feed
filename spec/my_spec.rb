require 'spec_helper'
require 'twitter'

describe "My behaviour" do

  it "can stub twitter home timeline" do
    tweets = Array.new
    expected_tweet = FactoryGirl.build(:tweet)
    tweets << expected_tweet

    Twitter.stubs(:home_timeline).returns(tweets)

    actual_tweets = Twitter.home_timeline

    actual_tweets.count.should == 1
    actual_tweets[0].id.should == expected_tweet.id
  end

end