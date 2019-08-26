class Feed
  attr_accessor :items, :title, :updated

  def initialize
    @items = Array.new
  end
end