atom_feed :language => 'en-US' do |feed|
  feed.title("TweetFeed")
  feed.subtitle("Tweets with URLs in ChrisEdwards357 home timeline.")
  feed.updated(Time.now)

  @feed.items.each do |post|
    next if post.updated.blank?

    feed.entry(post, { id: post.id, url: post.link } ) do |entry|
      entry.title post.title
      entry.summary post.summary
      #entry.author.name @author_name

      # the strftime is needed to work with Google Reader.
      entry.updated(post.updated.strftime("%Y-%m-%dT%H:%M:%SZ"))
      entry.author do |author|
        author.name(post.author)
      end

      entry.content post.content, :type => 'html'
    end
  end
end