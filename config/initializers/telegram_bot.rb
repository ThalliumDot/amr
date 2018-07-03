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
        post(['t', ENV['BOT_WEBHOOKS_TOKEN'], 'webhook'].join('/'), params)
        UpdatesPoller.add(bot, controller) if Telegram.bot_poller_mode?
      end

    end
  end
end
