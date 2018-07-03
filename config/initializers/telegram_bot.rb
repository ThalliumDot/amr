# IDK why but seems like telegram-bot doesn't read secrets.yml so
# we read it here

Telegram.bots_config = {
  default: Rails.application.secrets.telegram[:bot]
}

# patch telegram-bot method to use our own webhook

module Telegram
  module Bot
    module RoutesHelper

      # Define route which processes requests using given controller and bot.
      #
      #   telegram_webhook TelegramController, bot
      #
      #   telegram_webhook TelegramController
      #   # same as:
      #   telegram_webhook TelegramController, :default
      #
      #   # pass additional options
      #   telegram_webhook TelegramController, :default, as: :custom_route_name
      def telegram_webhook(controller, bot = :default, **options)
        bot = Client.wrap(bot)
        params = {
          to: Middleware.new(bot, controller),
          as: RoutesHelper.route_name_for_bot(bot),
          format: false,
        }.merge!(options)
        
        # change this variable when working with multiple bots
        # for example instead of `../webhook` at the end use `../#{bot.username}`
        # (and don't forget to make related changes to `lib/tasks/webhooks.rake`)
        webhook_url = ['t', ENV['BOT_WEBHOOKS_TOKEN'], 'webhook'].join('/')

        post(webhook_url, params)
        UpdatesPoller.add(bot, controller) if Telegram.bot_poller_mode?
      end

    end
  end
end
