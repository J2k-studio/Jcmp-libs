# telegram 0.1.0

A bot of Telegram. `#import <telegram>` (needs `web`; `jc lib install web`). Make a bot with @BotFather and keep its token secret.

```jk
Telegram bot = Telegram::bot(token);
bot.send(chat, "hello");                       // Result<int, Error>
TgUpdates up = ...bot.poll(next, 25)...;        // Result<TgUpdates, Error>: waits up to 25 s for news
up.count(), up.get(i) -> TgMessage { update_id, chat, from, text }, up.next
bot.me()                                       // Result<String, Error>: the user name of the bot
Telegram::bot_at("http://127.0.0.1:8081", token)   // another server (a test server)
```
Text messages only in this version (other updates are skipped but counted in `up.next`). A wrong token or a refusal of Telegram is an `Error` with the words of Telegram ("Telegram: Unauthorized"). Example: `examples/telegram_echo.jk`.
