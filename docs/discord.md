# discord 0.1.0

A bot of Discord (the REST part). `#import <discord>` (needs `web`). Make the bot in the developer portal (discord.com/developers), turn on "Message Content Intent" to read text, invite it to your server, and keep the token secret.

```jk
Discord bot = Discord::bot(token);
bot.send("CHANNEL-NUMBER", "hello");                        // Result<int, Error>; numbers are text (Discord numbers are big)
Result<DcMessages, Error> r = bot.messages(channel, last, 20);   // after the message `last` ("" = the newest), oldest first
ms.count(), ms.get(i) -> DcMessage { id, author, by_bot, text }, ms.last
Discord::bot_at("http://127.0.0.1:8082", token)             // another server (a test server)
```
A refusal of Discord is an `Error` with its words ("Discord: 401: Unauthorized (HTTP 401)"; HTTP 429 means you asked too fast). Do not answer to messages with `by_bot` (yours too). The Gateway (events as they happen) comes in the next version: it uses `websocket`.
