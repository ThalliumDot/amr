class InlineMessagesService

  LINK_REGEXP = /((http|https):\/\/)/
  GPM_LINK_REGEXP = /(https:\/\/play.google.com\/music\/\S+)/

  include ActiveModel::Validations

  validate :message_links

  attr_reader :original_msg, :parts
  attr_internal_reader :random_key

  def initialize(query)
    @_random_key = SecureRandom.hex(20)
    @original_msg = query
    @parts = split_message(query)
    valid?
    self
  end


  private


  def split_message(original_message)
    links = []

    replaced_links = original_message.gsub(GPM_LINK_REGEXP).with_index do |match, i|
      links << match
      "link-#{random_key}[#{random_key}number#{i}]link-#{random_key}"
    end

    return nil if links.empty?

    replaced_links.split("link-#{random_key}").map do |part|
      part.match(/\A\[#{random_key}number(\d*)\]\z/) { |m| m.to_s.to_i } || part.strip
    end
  end

  def message_links
    if original_msg.match(LINK_REGEXP)
      original_msg.match(GPM_LINK_REGEXP) ? true : errors.add(:base, 'Your message contains incorrect link')
    else
      errors.add(:base, 'Please, provide URL')
    end
  end

end
