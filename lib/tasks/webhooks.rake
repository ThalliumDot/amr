require 'httpclient'

namespace :webhooks do
  desc "Set webhook for app"
  task set: :environment do
    json = Hash[:url, our_webhook_url]
    resp = client.post(set_webhook_url, json.to_json)

    resp_description = JSON.parse(resp.body)['description']

    if_status_200(resp) do |body|
      puts "#{body['description']}: `#{our_webhook_url}`"
    end
  end

  desc "Remove webhook for app"
  task remove: :environment do
    resp = client.post(remove_webhook_url)

    if_status_200(resp) do |body|
      puts "#{body['description']}: `#{our_webhook_url}`"
    end
  end

  desc "Get information about hooks"
  task status: :environment do
    resp = client.get(webhook_info_url)
    if_status_200(resp) do |body|
      url = body['result']['url']
      puts "[#{url.present? ? 'OK' : 'NO-WEBHOOK'}] `#{our_webhook_url}`: \n #{JSON.pretty_generate(body)}"
    end
  end
end

def if_status_200(resp)
  if resp.status == 200
    yield(JSON.parse(resp.body))
  else
    puts "[#{resp.status}]: \n #{JSON.pretty_generate(JSON.parse(resp.body))}"
  end
end

def our_webhook_url
  [ENV['DOMAIN'], 't', ENV['BOT_WEBHOOKS_TOKEN'], 'webhook'].join('/')
end

def client
  HTTPClient.new(default_header: { 'Content-Type' => 'application/json' })
end

def webhook_info_url
  telegram_bot_url.concat('getWebhookInfo')
end

def remove_webhook_url
  telegram_bot_url.concat('deleteWebhook')
end

def set_webhook_url
  telegram_bot_url.concat('setWebhook')
end

def telegram_bot_url
  "https://api.telegram.org/bot#{ENV['BOT_TOKEN']}/"
end
