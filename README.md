# Antizashquer Music Records (c) site and bot

## Development

### Bot development

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
