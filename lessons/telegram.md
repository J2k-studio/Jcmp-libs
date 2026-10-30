# Lesson: `<telegram>` - a bot that answers

**Install:** `jc lib install web telegram`   **Use:** `#import <telegram>`   **Version:** 0.1.0

Make the bot in the chat with **BotFather** on Telegram (`/newbot`): you get a **token** like `123456:ABC...`. Keep it secret (never in a file you share, never in git); read it from the environment: `export TG_TOKEN=...`.

## Syntax
| what | form | gives |
|---|---|---|
| the bot | `Telegram::bot(String token)` | `Telegram` |
| another server (tests) | `Telegram::bot_at(String base, String token)` | `Telegram` (`"http://127.0.0.1:8081"`) |
| who am I | `bot.me()` | `Result<String, Error>` (the user name of the bot) |
| send | `bot.send(int chat, String text)` | `Result<int, Error>` |
| wait for news | `bot.poll(int offset, int seconds)` | `Result<TgUpdates, Error>` (long polling: waits up to `seconds`) |
| the news | `up.count()`, `up.get(i)`, `up.next` | `TgMessage` `m.update_id`, `m.chat`, `m.from`, `m.text`; `up.next` is the offset for the next poll |
Only text messages are given (other updates are skipped but counted in `up.next`). Text with quotes or newlines is escaped for you.

## Step 1: who am I?
```jk
#import <stdlib>
#import <telegram>

int main() {
    String token = "";
    switch Env::get("TG_TOKEN") { Option::Some(t): { token = t + ""; } Option::None: { } }
    if token.len == 0 { cout << "export TG_TOKEN=... first\n"; return 1; }
    Telegram bot = Telegram::bot(token);
    switch bot.me() {
        Result::Ok(name): { cout << "I am @" << name << "\n"; }
        Result::Err(e): { cout << "Telegram says: " << e.message << "\n"; }       // 401 means the token is wrong
    }
    return 0;
}
```

## Step 2: an echo bot
```jk
#import <stdlib>
#import <telegram>

int main() {
    String token = "";
    switch Env::get("TG_TOKEN") { Option::Some(t): { token = t + ""; } Option::None: { } }
    if token.len == 0 { return 1; }
    Telegram bot = Telegram::bot(token);
    int next = 0;
    while true {
        switch bot.poll(next, 25) {
            Result::Ok(up): {
                for i in 0..up.count() {
                    TgMessage m = up.get(i);
                    bot.send(m.chat, "you said: " + m.text);
                }
                next = up.next;                       // so that a message is not given twice
            }
            Result::Err(e): { cout << e.message << "\n"; return 1; }
        }
    }
    return 0;
}
```

## Step 3: commands
A bot is a function from the text to the answer. Keep that function separate: it can be tested without Telegram.
```jk
#import <stdlib>

String answer(String text) {
    if text == "/start" { return "Hello! Send /time or any text."; }
    if text.starts_with("/echo ") { return text.slice(6, text.len) + ""; }
    if text == "/time" { return "It is " + str(Time::now_ms() / 1000 % 86400 / 3600) + " o'clock (UTC)."; }
    return "I do not know that. Try /start";
}

int main() {
    cout << answer("/start") << "\n" << answer("/echo hi") << "\n" << answer("what?") << "\n";
    return 0;
}
```
In the loop call `bot.send(m.chat, answer(m.text))`.

## Things to know
* `poll` waits (up to 25 s): the program uses little energy while it waits.
* Telegram refuses messages that come too fast to one chat; send what is needed.
* A bot sees only the chats where it was written to or added.

## Exercises
1. Add `/help` that lists the commands.
2. Remember the last message of each chat (a `Map<int, String>`) and answer `/again` with it.
3. Test `answer()` with `#expect`-style checks in a program of its own.

**Next:** `<discord>`; `<web>` for any other API.
