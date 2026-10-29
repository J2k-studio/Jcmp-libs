# discord 0.2.0

A bot of Discord (the REST part). `#import <discord>` (needs `web`). Make the bot in the developer portal (discord.com/developers), turn on "Message Content Intent" to read text, invite it to your server, and keep the token secret.

```jk
Discord bot = Discord::bot(token);
bot.send("CHANNEL-NUMBER", "hello");                        // Result<int, Error>; numbers are text (Discord numbers are big)
Result<DcMessages, Error> r = bot.messages(channel, last, 20);   // after the message `last` ("" = the newest), oldest first
ms.count(), ms.get(i) -> DcMessage { id, author, by_bot, text }, ms.last
Discord::bot_at("http://127.0.0.1:8082", token)             // another server (a test server)
```
A refusal of Discord is an `Error` with its words ("Discord: 401: Unauthorized (HTTP 401)"; HTTP 429 means you asked too fast). Do not answer to messages with `by_bot` (yours too). 

## The Gateway (events as they happen) -- needs `websocket`
```jk
switch Gw::connect(token, Gw::intents()) {            // intents: servers, server messages, direct messages, message text
    Result::Ok(gw): {
        while true {
            DcEvent e = gw.next(1000);                 // waits at most 1000 ms; sends the heartbeat itself, so call it often
            if e.kind == "MESSAGE_CREATE" && !e.by_bot { bot.send(e.channel, "you said: " + e.text); }
            if e.kind == "CLOSED" || e.kind == "RECONNECT" || e.kind == "INVALID_SESSION" { break; }
        }
    }
    Result::Err(e): { cout << e.message << "\n"; }
}
```
`e.kind` is "" when nothing came. Events: READY, MESSAGE_CREATE (`id`, `channel`, `author`, `by_bot`, `text`), any other event by its name (`e.raw` = its JSON). No resume yet: after CLOSED connect again. Turn on "Message Content Intent" in the developer portal or `text` stays empty.
