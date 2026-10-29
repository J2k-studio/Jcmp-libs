# web 0.1.0

An HTTP client for APIs: any method, headers, a body, the status code, over http and https (TLS). `#import <web>` (it imports `<net>`).

```jk
#import <stdlib>
#import <web>
void main() {
    Result<HttpResponse, Error> rr = Web::get("https://api.github.com/zen", "User-Agent: demo");
    switch rr {
        Result::Ok(r): { cout << r.status << " " << r.body << "\n"; }
        Result::Err(e): { cout << "failed: " << e.message << "\n"; }
    }
}
```
* `Web::request(method, url, headers, body)`, `Web::get(url, headers)`, `Web::post_json(url, headers, json)`, `Web::post_form(url, headers, "a=1&b=2")`: `headers` is text with one header a line (`"A: x\r\nB: y"`, "" for none). Redirects (301 302 303 307 308) are followed up to 5 times; chunked answers are put together.
* `HttpResponse`: `status`, `head` (the header lines), `body`, `r.header("content-type")` (any case). A status of 400 or more is **not** an error: the text of the API is in `body`. Only a connection that fails is an `Error`.
* `Web::url_encode(s)`: the text for a query (`a b` -> `a%20b`).
