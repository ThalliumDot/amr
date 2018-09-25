class InlineMessagesService

  LINK_REGEXP = /((http|https):\/\/)/
  GPM_LINK_REGEXP = /(https:\/\/play.google.com\/music\/\S+)/

  include ActiveModel::Validations

  validate :message_links

  attr_reader :original_msg, :parts, :image_url
  attr_internal_reader :random_key

  # TODO: disable preview option


  def initialize(query)
    @_random_key  = SecureRandom.hex(20)
    @original_msg = query
    @parts        = split_message(query)
    @image_url    = nil
    valid?
    self
  end

  def generate_response

  end

  def to_article
    parts.map do |part|
      if part.is_a?(GPMProcessor)
        @image_url ||= part.image_url
        part.transform
      else
        part
      end
    end.join("\n\n")
  end


  private


  def split_message(original_message, parts = [])
    return parts if original_message.blank?

    partitions    = original_message.partition(GPM_LINK_REGEXP).each(&:strip!)
    partitions[1] = GPMProcessor.new(partitions[1]) if partitions[1].present?

    parts.concat(partitions[0..1]).delete_if(&:blank?)
    split_message(partitions[2], parts)
  end

  def message_links
    if original_msg.match(LINK_REGEXP)
      original_msg.match(GPM_LINK_REGEXP) ? true : errors.add(:base, 'Your message contains incorrect link')
    else
      errors.add(:base, 'Please, provide URL')
    end
  end

end
