require 'factory_girl'

FactoryGirl.define do

  factory :url, class: Twitter::Entity::Url do
    url "http://localhost/#{Random.rand(1..32768).to_s}/"
    display_url { "#{url}display/"}
    expanded_url { "#{url}expanded/"}

    initialize_with { new(attributes) }
  end

end