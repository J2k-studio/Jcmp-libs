# websocket 0.1.0

A WebSocket client (RFC 6455) over `ws://` and `wss://`. `#import <websocket>` (needs `net`).

```jk
switch Ws::connect("wss://gateway.discord.gg/?v=10&encoding=json", "") {
    Result::Ok(ws): {
        ws.send_text("{\"op\":1,\"d\":null}");
        WsMessage m = ws.recv();          // blocks for the next whole message
        cout << m.kind << " " << m.text << "\n";   // 1 text, 2 binary, 8 closed (text = the reason)
        ws.close();
    }
    Result::Err(e): { cout << e.message << "\n"; }
}
```
* `Ws::connect(url, headers)`: the handshake; `headers` are extra lines separated by `\r\n` ("" for none). A server that does not answer 101 is an `Error`.
* `ws.send_text(s)`, `ws.send_binary(s)`: masked frames, any size. `ws.recv()`: pings are answered, pongs skipped, fragments joined; a close frame (or a lost connection) gives `kind` 8. `ws.close()`.
* `recv` blocks: put it in a thread (`<tasks>`) when the program has other work. `Sec-WebSocket-Accept` is not checked yet (no SHA-1 in the standard library); the status 101 is.
Tested against a pretend server: text both ways (Thai too), ping/pong, fragments, a 70000-byte message, close.
