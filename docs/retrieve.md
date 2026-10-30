# retrieve 0.1.0

Search in your own texts with BM25. `#import <retrieve>`.

| call | gives | what it does |
|---|---|---|
| `Retrieve::make()` | `Retrieve` | an empty index |
| `r.add(name, text)` | | add a document; it is cut into passages at blank lines and before lines that start with `#` |
| `r.build()` | | call once after the last `add` |
| `r.search(question, k)` | `Hits` | the best `k` passages |
| `h.n`, `h.names[i]`, `h.texts[i]`, `h.scores[i]` | | the number of hits and, for each, its document, text and score |

```
#import <retrieve>
int main() {
    Retrieve r = Retrieve::make();
    r.add("files.md", "# Files\n\nTo open a file use Fs::read.\n");
    r.add("math.md", "# Math\n\nMath::sqrt is the square root.\n");
    r.build();
    Hits h = r.search("open a file", 1);
    cout << h.names[0] << "\n";           // files.md
    return 0;
}
```

Words are lower-case letters, digits and `_`. Text without spaces (Thai) is cut into pairs of characters, so a Thai question finds a Thai passage. A word in every passage counts for nothing; a rare word counts a lot. `Retrieve` holds arrays, so keep it in a global or pass it by reference, not by value. The tool `ask` (Jcmp-Tools) is built on it.
