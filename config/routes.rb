Rails.application.routes.draw do
  telegram_webhook TelegramWebhooksController

  # scope path: "t/#{ENV['BOT_WEBHOOKS_TOKEN']}" do
  #   match '/webhook', to: 'telegram_webhooks#update', via: [:post, :put, :patch]
  # end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
