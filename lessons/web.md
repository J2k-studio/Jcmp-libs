# Lesson: `<web>` - asking the net

**Install:** `jc lib install web`   **Use:** `#import <web>`   **Version:** 0.1.0

`<web>` is an HTTP client for the APIs of the net (`http` and `https`). One call makes one request and gives the **status** (200 good, 404 not found, ...), the **headers** and the **body**. A status of 400 or more is *not* an `Error`: the body usually says why. Only a connection that fails is an `Error`.

## Syntax
| what | form | gives |
|---|---|---|
| any request | `Web::request(String method, String url, String headers, String body)` | `Result<HttpResponse, Error>` |
| GET | `Web::get(String url, String headers)` | the same |
| POST with JSON | `Web::post_json(String url, String headers, String json)` | the same (adds `Content-Type: application/json`) |
| POST a form | `Web::post_form(String url, String headers, String form)` | the same (`a=1&b=2`) |
| make a text safe for an address | `Web::url_encode(String s)` | `String` |
| the answer | `r.status` (`int`), `r.head` (all header lines), `r.body` (`String`), `r.header(String name)` | the value of a header, any case, `""` when it is not there |
`headers` are lines separated by `\r\n`, for example `"Authorization: Bearer KEY\r\nAccept: text/plain"`. Redirects (301 302 303 307 308) are followed, at most 5 times. Chunked answers are put together. One request uses one connection.

## Step 1: a GET
```jk
#import <stdlib>
#import <web>

int main() {
    switch Web::get("https://example.org/", "") {
        Result::Ok(a): {
            cout << a.status << " " << a.body.len << " bytes, type " << a.header("content-type") << "\n";
        }
        Result::Err(e): { cout << "no answer: " << e.message << "\n"; }
    }
    return 0;
}
```

## Step 2: send JSON, read JSON
```jk
#import <stdlib>
#import <web>

int main() {
    String body = "{\"question\":\"hello\"}";
    switch Web::post_json("https://example.org/api", "Authorization: Bearer my-key", body) {
        Result::Ok(a): {
            if a.status >= 400 { cout << "the service says " << a.status << ": " << a.body << "\n"; return 1; }
            switch Json::parse(a.body) {
                Result::Ok(d): { int n = d.get(0, "answer"); if n >= 0 { cout << d.text(n) << "\n"; } }
                Result::Err(e2): { cout << "the answer is not JSON\n"; }
            }
        }
        Result::Err(e): { cout << "no answer: " << e.message << "\n"; }
    }
    return 0;
}
```

## Step 3: put a value in an address
```jk
#import <stdlib>
#import <web>

int main() {
    String city = "Chiang Mai & Lamphun";
    String url = "https://example.org/search?q=" + Web::url_encode(city) + "&n=3";
    cout << url << "\n";                       // https://example.org/search?q=Chiang%20Mai%20%26%20Lamphun&n=3
    return 0;
}
```

## Things to know
* Never write a real key in a file you share: read it from an environment variable (`Env::get("KEY")`).
* Do not ask too fast: a service that answers 429 wants you to wait.
* `https` checks the certificate chain; a refused certificate is an `Error` with the reason.
* The body of a big download is held in memory: for files use `jget`.

## Exercises
1. Print only the status of three addresses (one that does not exist).
2. Ask an API for JSON and print one field with `Json`.
3. Write `fetch(url)` that returns the body or `""` and prints the error to `cerr`.

**Next:** `<telegram>`, `<discord>` (bots made with `<web>`), `<websocket>` (a connection that stays open).
