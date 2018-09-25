require 'httpclient'
require 'nokogiri'

class InlineMessagesService::GPMProcessor

  # TODO: recognize link to artist only or playlist

  GENRE_REGEXP = -> (album, artist) {
    /"#{Regexp.quote(artist)}","#{Regexp.quote(album)}","#{Regexp.quote(artist)}",[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,"(.*?)",/
  }

  include ActiveModel::Validations

  attr_reader :link, :content, :type, :image_url


  def initialize(link)
    @link = link
    @image_url = nil
    @content = {}
    @type = nil

    process_link!
  end

  def transform
    "#{[content[:artist], (content[:song] || content[:album])].compact.join(' - ')} \n"\
    "[GPM](#{link}) | iTunes"
  end


  private


  def process_link!
    page = Nokogiri::HTML(call_gpm(link))
    @image_url = page.at('meta[property="og:image"]')&.to_h&.dig('content')
    detailed_link = page.at('a')&.values&.[](0)

    return unless detailed_link # TODO: start from detailed link

    raw_page = call_gpm("https://play.google.com/#{detailed_link}&hl=en")

    recognize_content!(Nokogiri::HTML(raw_page)&.at('body')&.first_element_child)

    if type == :song || type == :album
      raw_page.match(GENRE_REGEXP.call(content[:album], content[:artist])) do |match|
        content[:genre] = match[1]
      end
    end
  end

  def recognize_content!(first_child)
    case first_child['itemtype']
      when 'http://schema.org/MusicRecording/PlayMusicTrack'
        @type = :song
        content[:artist] = first_child.at('div[itemprop="byArtist"]')&.text
        content[:album]  = first_child.at('div[itemprop="inAlbum"]')&.text
        content[:song]   = first_child.at('div[itemprop="name"]')&.text
      when 'http://schema.org/MusicAlbum/PlayMusicAlbum'
        @type = :album
        content[:artist] = first_child.at('div[itemprop="byArtist"]')&.text
        content[:album]  = first_child.at('div[itemprop="name"]')&.text
      when 'http://schema.org/ItemList'
        @type = :artist
        content[:artist] = first_child.first_element_child&.text
      else
        errors.add(:base, 'Cant process page')
        return
    end
  end

  def call_gpm(url)
    resp = HTTPClient.get(url)
    case resp.status
    when 200
      resp.body
    when 404
      errors.add(:base, 'URL is invalid')
    else
      errors.add(:base, 'URL seems to be invalid')
    end
  end

end
