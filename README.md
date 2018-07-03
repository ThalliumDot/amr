# Antizashquar Music Records (c) site and bot

## Development

## Bot development 

### Use as boilerplate

If you want to use this repo as boilerplate, you can simply checkout on
`telegram-bot-setup` branch and move on! Just keep in mind that it was 
created to host one bot on server. So that, our approach to generate 
webhook urls doesn't handle multiple bots, but you can change this 
behaviour in `config/initializers/telegram_bot.rb` file (and don't 
forget to fix `lib/tasks/webhooks.rake` to create webhooks properly).

A few words about "our approach to generate webhook urls". 
[Telegram API documentation recommends](https://core.telegram.org/bots/api#setwebhook) 
to use some sort of 'token' directly in webhook url, e.g. 
`https://my.site/my-awesome-token-qewrwtwdhsfhkjafsdk`. But we couldn't 
find how to do it with `telegram-bot` gem we use. So we changed 
approach from this (the default):  
`/telegram/1111111_AAAA-AAAAAA-AAAAA`  
where you can find a slightly changed token of your telegram bot, to this:  
`/t/<bot-webhooks-token>/webhook`.

We think it a bit more secure and configurable, since that token is
simply living at `BOT_WEBHOOKS_TOKEN` environment variable or in `.env` file.

### Development with webhooks

Telegram Bot development requires at-least https self-signed sertificate.
But instead of creating this sertificate and long tuning your machine to 
work with it, you can simply use [ngrok](https://ngrok.com/download).

Just register, download and start it with following command, alongside
with rails server.

```
./ngrok http 3000
```

It will work just fine **BUT** don't forget to specify ngrok url in `.env`.

```
# .env
...

DOMAIN=https://123abcd.ngrok.io
...
```

After you specify this variable simply run `rails webhooks:set` to set the 
webhook on that domain.

### Predefined rake tasks

This project contains 3 predefined tasks:

```
rake webhooks:remove                    # Remove webhook for app
rake webhooks:set                       # Set webhook for app
rake webhooks:status                    # Get information about hook
```
