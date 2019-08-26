require 'nokogiri'
require 'twitter'
require 'net/http'
require 'uri'
require 'twitter'
require 'readability'
require 'open-uri'
require 'rss'
require 'nokogiri'
require 'parallel'

class FeedsController < ApplicationController
  layout false


  def strip_html(str)
    document = Nokogiri::HTML.parse(str)
    document.css("br").each { |node| node.replace("\n") }
    document.text
  end

  def exclude?(url)
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      response = http.request_head(uri.path)
      content_type = response['content-type'] || ""
      file_size = response['content-length'].to_i # || 0

      logger.info "Content-Type:#{content_type}, Content-Length:#{file_size}"

      !content_type.downcase.include?("text/html") || file_size > 200000
    end
  end

  def build_feed_item(tweet)
    url = tweet.urls[0]
    #tweet.urls.each { |url|

    item = FeedEntry.new

    begin
      logger.info "---"
      logger.info "Processing tweet: #{tweet.text}"
      logger.info "  Expanded URL: #{url.expanded_url}"

      # restrict max size of content
      uri = URI.parse(url.expanded_url)
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.request_head(uri.path)
      content_type = response.content_type || ""
      content_length = response.content_length || 0
      last_modified = response['last-modified']

      logger.info "  Content-Type: #{content_type}"
      logger.info "  Content-Length: #{content_length}"
      logger.info "  Last-Modified: #{last_modified}"

      if !content_type.downcase.include?("text/html")
        logger.info "  SKIPPING: Content-Type not text/html"
        return nil
      end
      if content_length > 200000
        logger.info "  SKIPPING: Content-Length too large."
        return nil
      end

      # Set last modified from http header.
      if last_modified
        item.created_at = Time.parse(response['last-modified'])
      else
        item.created_at = tweet.created_at
      end

      # read the url and make it readable.
      source = open(url.expanded_url).read
      doc = Readability::Document.new(source, :tags => %w[a div p h1 h2 h3 h4 h5 h6 strong b i em pre blockquote ul ol li img], :attributes => %w[src href width height alt title])
    rescue => e
      logger.error "  ERROR: #{e.message}"
      logger.error e.backtrace.join("\n")
      return nil
    end

    item.id = tweet.id
    item.link = url.expanded_url
    item.title = doc.title
    item.author = doc.author
    item.updated = tweet.created_at
    item.summary = "@#{tweet.user.screen_name} (#{tweet.user.name}) - #{tweet.text}"
    item.content = "<p><strong>@#{tweet.user.screen_name}<em>(#{tweet.user.name})</em></strong> - <em>#{tweet.text}</em></p><p>--</p>#{doc.content.encode("utf-8")}"

    #@feed.items << item
    item
    #}
  end

  def index
    
    # Config (move to ENV vars and secure them)
    Twitter.configure { |config|
      config.consumer_key = "<CONSUMER_KEY_HERE>"
      config.consumer_secret = "<CONSUMER_SECRET_HERE>"
      config.oauth_token = "<OAUTH_TOKEN_HERE>"
      config.oauth_token_secret = "<OAUTH_TOKEN_SECRET_HERE>"
    }

    @feed = Feed.new
    @feed.title = "URLs tweeted by people I follow"
    @feed.updated = Time.now

    url_tweets = Twitter.home_timeline(:count => 60).find_all { |t| t.urls.count > 0 }
    logger.info "Retrieved #{url_tweets.count} tweets with urls."

    items = Parallel.map(url_tweets, :in_threads => 20) { |tweet|
    #items = url_tweets.map { |tweet|
      build_feed_item(tweet)
    }

    items = items - [nil]
    items.sort { |x,y| x.updated <=> y.updated }
    items.each do |item|
      @feed.items << item
    end
  end
end

