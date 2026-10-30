# Lesson: `<discord>` - a bot for a server, by asking or by listening

**Install:** `jc lib install web websocket discord`   **Use:** `#import <discord>`   **Version:** 0.2.0

Make the bot in the **developer portal** (discord.com/developers): a new application, a Bot, copy its **token** (secret!), turn on **Message Content Intent**, and invite the bot to your server with the OAuth2 link. Channel numbers are huge, so channels and messages are **text** in J2K.

## Syntax: REST (asking)
| what | form | gives |
|---|---|---|
| the bot | `Discord::bot(String token)`, `Discord::bot_at(String base, String token)` | `Discord` |
| send | `bot.send(String channel, String text)` | `Result<int, Error>` |
| read | `bot.messages(String channel, String after, int limit)` | `Result<DcMessages, Error>`: `ms.count()`, `ms.get(i)`, `ms.last` (the id of the newest); oldest first |
| a message | `m.id`, `m.author`, `m.by_bot`, `m.text` | |

## Syntax: Gateway (listening)
| what | form | gives |
|---|---|---|
| connect | `Gw::connect(String token, int intents)`, `Gw::connect_at(String url, ...)` | `Result<DiscordGateway, Error>` |
| the intents | `Gw::intents()` | servers + server messages + direct messages + message text |
| the next event | `gw.next(int wait_ms)` | `DcEvent` (`e.kind` is `""` when nothing came); the heartbeat is sent inside, so call it often |
| events | `e.kind` `"READY"`, `"MESSAGE_CREATE"` (`e.id`, `e.channel`, `e.author`, `e.by_bot`, `e.text`), any other name (`e.raw` has its JSON), `"CLOSED"`, `"RECONNECT"`, `"INVALID_SESSION"` | |
| close | `gw.close()` | |

## Step 1: say hello in a channel
```jk
#import <stdlib>
#import <discord>

int main() {
    Discord bot = Discord::bot("TOKEN-of-the-bot");
    switch bot.send("123456789012345678", "hello from J2K") {
        Result::Ok(x): { cout << "sent\n"; }
        Result::Err(e): { cout << "failed: " << e.message << "\n"; }       // 401: the token is wrong; 403: the bot may not write there
    }
    return 0;
}
```

## Step 2: read what was written since the last time
```jk
#import <stdlib>
#import <discord>

int main() {
    Discord bot = Discord::bot("TOKEN-of-the-bot");
    String last = "";
    switch bot.messages("123456789012345678", last, 20) {
        Result::Ok(ms): {
            for i in 0..ms.count() {
                DcMessage m = ms.get(i);
                if !m.by_bot { cout << m.author << ": " << m.text << "\n"; }
            }
            last = ms.last;                                       // give it next time: only newer messages come
        }
        Result::Err(e): { cout << e.message << "\n"; }
    }
    return 0;
}
```

## Step 3: answer at once with the Gateway
```jk
#import <stdlib>
#import <discord>

int main() {
    String token = "TOKEN-of-the-bot";
    Discord bot = Discord::bot(token);
    switch Gw::connect(token, Gw::intents()) {
        Result::Ok(gw): {
            bool run = true;
            while run {
                DcEvent e = gw.next(1000);
                if e.kind == "MESSAGE_CREATE" && !e.by_bot { bot.send(e.channel, "you said: " + e.text); }
                if e.kind == "CLOSED" || e.kind == "RECONNECT" || e.kind == "INVALID_SESSION" { run = false; }
            }
        }
        Result::Err(e): { cout << e.message << "\n"; }
    }
    return 0;
}
```

## Things to know
* Answer only to people (`!e.by_bot`), or two bots will talk to each other for ever (yours too).
* Without "Message Content Intent" the text of messages is empty.
* HTTP 429 means "too fast": wait the time it says.
* After `"CLOSED"` connect again (there is no resume yet).

## Exercises
1. Make a `!roll` command that answers with a number from 1 to 6 (`Random::`).
2. Keep a count of the messages per author and answer `!top`.
3. Run the bot in the background with `jsh` and `nohup`, and stop it with a message `!stop` from you.

**Next:** `<websocket>` (what the Gateway is made of), `<web>`.
