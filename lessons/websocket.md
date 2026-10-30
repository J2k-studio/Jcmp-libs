# Lesson: `<websocket>` - a connection that stays open

**Install:** `jc lib install websocket`   **Use:** `#import <websocket>` (it needs `net`; secure `wss://` uses TLS 1.3)   **Version:** 0.2.0

A normal HTTP request asks once and gets one answer. A **WebSocket** stays open in both directions: the server can send a message whenever it has one, and you can send whenever you want. Chats, games, live prices and the Gateway of Discord work this way.

## Syntax
| what | form | gives |
|---|---|---|
| connect | `Ws::connect(String url, String headers)` | `Result<WebSocket, Error>`; `url` is `ws://host:port/path` or `wss://host/path`; `headers` are extra lines separated by `\r\n` (`""` for none) |
| send | `ws.send_text(String s)`, `ws.send_binary(String s)` | `bool` (false when the connection is gone) |
| receive, wait | `ws.recv()` | `WsMessage`: the next whole message (pings are answered inside, pieces are joined) |
| receive, wait a little | `ws.recv_wait(int ms)` | `WsMessage`; `kind` 0 when nothing came in `ms` milliseconds (the connection stays open) |
| the message | `m.kind`, `m.text` | kind 1 = text, 2 = binary, 8 = closed (`text` is the reason), 0 = nothing yet |
| the socket | `ws.fd()` | the file number under the connection (for `poll`) |
| close | `ws.close()` | `void` |
A server must answer the handshake with the status 101; the key it returns is not checked (no SHA-1 in the standard library yet).

## Step 1: connect, say hello, read one answer
```jk
#import <stdlib>
#import <websocket>

int main() {
    switch Ws::connect("wss://example.org/socket", "") {
        Result::Ok(ws): {
            ws.send_text("hello");
            WsMessage m = ws.recv();                       // waits for the answer
            if m.kind == 8 { cout << "the server closed: " << m.text << "\n"; }
            else { cout << "got " << m.text.len << " bytes: " << m.text << "\n"; }
            ws.close();
        }
        Result::Err(e): { cout << "cannot connect: " << e.message << "\n"; }
    }
    return 0;
}
```

## Step 2: do not wait for ever
`recv` blocks. A program that has other things to do (draw a screen, send a heartbeat) uses `recv_wait` with a short time and does its work between the calls.
```jk
#import <stdlib>
#import <websocket>

int main() {
    switch Ws::connect("wss://example.org/socket", "") {
        Result::Ok(ws): {
            int quiet = 0;
            while quiet < 5 {                               // stop after five quiet seconds
                WsMessage m = ws.recv_wait(1000);
                if m.kind == 0 { quiet += 1; ws.send_text("ping from me"); continue; }
                if m.kind == 8 { break; }
                quiet = 0;
                cout << "got: " << m.text << "\n";
            }
            ws.close();
        }
        Result::Err(e): { cout << e.message << "\n"; }
    }
    return 0;
}
```

## Things to know
* A message can be big (one frame of any size); the text of a message is a `String` that may hold any bytes.
* The program must send a **heartbeat** when the service asks for one (Discord does): see `<discord>`, which does it for you.
* A failed `connect` tells why: a wrong address, no network, a refused certificate, or "the server did not upgrade" (the address is not a WebSocket).

## Exercises
1. Connect to an echo server (`wss://echo.websocket.events`) and print what it sends back.
2. Make a loop that sends a number every second and prints the answers.
3. Handle the case `m.kind == 8`: print why it closed and connect again after two seconds.

**Next:** `<discord>` (the Gateway is a WebSocket with rules), `<web>` (one request, one answer).
