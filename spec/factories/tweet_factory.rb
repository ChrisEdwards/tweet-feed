require 'factory_girl'

FactoryGirl.define do

  factory :tweet, class: Twitter::Tweet do
    id Random.rand(1..32768)

    initialize_with { new(attributes) }

  end

  factory :tweet_with_url, parent: :tweet do
    ignore do
      url_count 1
    end

    after(:build) do |tweet, evaluator|
      evaluator.url_count.times do
        tweet.urls << FactoryGirl.build(:url)
      end
    end
  end
end

