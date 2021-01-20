require 'open-uri'

class ParsingService
  IMAGE_DEFAULT="news.jpg"
  DEFAULT_DETAIL_VALUE={
    image: "news.jpg",
    article_excerpt: "This is error link!"
  }

  def initialize url, origin_url
    @url = url
    @origin_url = origin_url
  end

  def proccess_detail
    source = open(url).read
    allowed_tags = %w[div p img a ul ol li h1 h2 h3 h4 h5 h6 blockquote strong em b code pre]
    Readability::Document.new(source, tags: allowed_tags, attributes: %w[src href], remove_empty_nodes: false).content 
  rescue
    false
  end

  def proccess_list
    body = Nokogiri::HTML(open(url), nil, 'UTF-8').css('body').first
    score_elements = body.css(".itemlist tr td.subtext")
    content = body.css(".itemlist tr.athing")
    content.to_a.map { |item| build_content(item, score_elements) }
  end

  private

  attr_reader :url, :origin_url

  def build_content item, score_elements
    id = item["id"]
    rank = item.css("span.rank").text
    puts rank
    story = build_story(item)
    detail_data = get_image(story[:url])
    comhead = build_comhead(item)
    last_score = score_elements.at_css("#score_#{id}").text
    user = score_elements.at_css("#score_#{id}").next_element.text
    comment_number = score_elements.css("a").last.text
    {
      id: id,
      rank: rank,
      story: story,
      comhead: comhead || {},
      last_score: last_score.gsub(/[^0-9]/, '').to_i,
      user: user,
      comment_number: comment_number.gsub(/[^0-9]/, '').to_i,
      detail_data: detail_data
    }
  end

  def build_story item
    story_object = item.at_css("a.storylink")
    url_content = story_object["href"].include?("http") ? story_object["href"] : "#{origin_url}/#{story_object['href']}"
    {
      content: story_object.content,
      url: url_content,
    }
  end

  def build_comhead item
    comhead_object = item.at_css(".sitebit a")
    return if comhead_object.blank?
    {
      content: comhead_object&.css("span")&.text,
      url: comhead_object["href"],
    }
  end

  def get_image link
    return DEFAULT_DETAIL_VALUE if link.exclude? "http"
      source = open(link).read
      rbody = Readability::Document.new(source, :tags => %w[div p img a], :attributes => %w[src href], :remove_empty_nodes => false, :do_not_guess_encoding => true)
      image = if rbody.images.first.present? && rbody.images.first.include?("http")
        rbody.images.first
      else
        IMAGE_DEFAULT
      end
      content = ActionController::Base.helpers.strip_tags(Readability::Document.new(source).content)
      article_excerpt = ActionController::Base.helpers.truncate(content, length: 125)
      
      {
        image: image,
        article_excerpt: article_excerpt
      }
  rescue
    DEFAULT_DETAIL_VALUE
  end
end
