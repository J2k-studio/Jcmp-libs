# Lesson: `<retrieve>` - find the right page in your own notes

**Install:** `jc lib install retrieve`   **Use:** `#import <retrieve>`

A search engine of your own: you give it texts, it gives back the passages that fit a question best. No model, no network.

## Syntax
| call | gives |
|---|---|
| `Retrieve::make()` | an empty index |
| `r.add(name, text)` | add a document (cut into passages at blank lines and at `#` lines) |
| `r.build()` | once, after the last `add` |
| `r.search(question, k)` | `Hits`: `h.n`, `h.names[i]`, `h.texts[i]`, `h.scores[i]` |

## Step 1: three small documents
```jk
#import <stdlib>
#import <retrieve>

int main() {
    Retrieve r = Retrieve::make();
    r.add("files.md", "# Files\n\nTo open a file use Fs::read to get the text of a file.\n\nA file is closed when the program ends.\n");
    r.add("math.md", "# Math\n\nMath::sqrt gives the square root of a number.\n");
    r.add("thai.md", "# ภาษาไทย\n\nการเปิดไฟล์ทำได้ด้วย Fs::read\n");
    r.build();
    Hits a = r.search("how do I open a file", 1);
    cout << a.names[0] << "\n";                 // files.md
    Hits b = r.search("square root", 1);
    cout << b.texts[0] << "\n";
    Hits c = r.search("เปิดไฟล์", 1);
    cout << c.names[0] << "\n";                 // thai.md
    return 0;
}
```

## Step 2: nothing found
```jk
#import <stdlib>
#import <retrieve>

int main() {
    Retrieve r = Retrieve::make();
    r.add("a.md", "# A\n\nhello world\n");
    r.build();
    Hits h = r.search("zzzz", 3);
    cout << h.n << "\n";                        // 0: a word that is in no passage finds nothing
    return 0;
}
```
Keep a `Retrieve` in a global variable if you give it to a function: it holds arrays, so passing it by value would move them.

## Exercises
1. Read every `.md` file of a folder with `Dir::list` and `Fs::read_text` and add it. Ask a question about your own notes.
2. Print the passage with its score, and cut it to the first 200 bytes.
3. Read the code of the tool `ask` and add an option that shows only the names of the files.
