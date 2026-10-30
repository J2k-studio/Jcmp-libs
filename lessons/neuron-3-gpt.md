# Lesson: `<neuron>` 3 - a language model that you train

**Use:** `#import <neuron>`   The tool: `neuron gpt train FILE|FOLDER` (`jc install neuron`)

A language model reads text and learns which letter (or word) comes next. `Gpt` is a small GPT: a table of vectors for the tokens and for the positions, blocks of **attention** (every place looks at the places before it and takes what it needs) and a layer that scores the next token. It works **byte by byte** (256 tokens), so Thai, English and code need no tokenizer.

## Syntax
| what | form |
|---|---|
| make | `Gpt::make(vocab, context, width, heads, layers, seed)` e.g. `Gpt::make(256, 64, 64, 4, 2, 1)`; `width / heads` must be a multiple of 4 |
| the text as numbers | `Gpt::bytes(String text)` -> `int[]` (0-255), `Gpt::text_of(int[] ids)` -> `String` |
| one learning step | `m.step(int[] data, int[] starts, double lr, double decay, double clip)` -> the mean loss; every number in `starts` is the place where a training sequence of `context + 1` numbers begins |
| check on text never learned | `m.loss_on(data, starts)` |
| write | `m.write(int[] prompt, int count, double temperature, int top_k, int seed)` -> `String` of the new tokens (`temperature` 0 = always the most likely; `top_k` 0 = any) |
| one token | `m.next_token(ids, temp, top_k)` |
| save, load | `m.save(path)` (weights as text + `path.cfg`), `Gpt::load(path)` (`vocab` is 1 when the files cannot be read) |

## Step 1: teach it a sentence
```jk
#import <stdlib>
#import <neuron>

Gpt m;

int main() {
    String text = "the cat sat on the mat. the dog sat on the log. ";
    String all = "";
    for r in 0..40 { all = all + text; }
    int[] data = Gpt::bytes(all);
    m = Gpt::make(256, 16, 32, 2, 1, 1);
    int seed = 1;
    for step in 0..200 {
        int[] starts = arr(5);
        for q in 0..4 { seed = (seed * 1103515245 + 12345) & 2147483647; starts.push(seed % (data.len - 20)); }
        double loss = m.step(data, starts, Sched::cosine(step, 200, 10, 0.02, 0.002), 0.0, 1.0);
        if step % 50 == 0 { cout << "step " << step << " loss " << loss << "\n"; }
    }
    cout << "[" << m.write(Gpt::bytes("the cat s"), 24, 0.0, 0, 1) << "]\n";
    m.save("cats.gpt");
    return 0;
}
```

## Step 2: keep a part aside and see if it learns or only remembers
```jk
#import <stdlib>
#import <neuron>

Gpt m;

int main() {
    String text = "one fish two fish red fish blue fish. ";
    String all = "";
    for r in 0..60 { all = all + text; }
    int[] data = Gpt::bytes(all);
    int cut = data.len * 9 / 10;                          // the last tenth is never learned
    m = Gpt::make(256, 16, 32, 2, 1, 1);
    int[] check = arr(4);
    for q in 0..4 { check.push(cut + q * 20); }           // places in the part kept aside
    int seed = 7;
    for step in 0..150 {
        int[] starts = arr(5);
        for q in 0..4 { seed = (seed * 1103515245 + 12345) & 2147483647; starts.push(seed % (cut - 20)); }
        m.step(data, starts, 0.02, 0.0, 1.0);
        if step % 50 == 49 { cout << "step " << (step + 1) << " check loss " << m.loss_on(data, check) << "\n"; }
    }
    return 0;
}
```

## From the shell
`neuron gpt train notes.txt` (one file) or `neuron gpt train docs/ size=medium minutes=10` (a folder, a bigger model, stops by itself); `neuron gpt write cats.gpt "the cat"`. It prints the **check** loss: if the loss on the learned text falls and the check does not, the model only remembers.

## Things to know
* A phone trains models of thousands to a few million numbers on megabytes of text: they learn the style and habits of the text, not the world. Use them for a narrow job with your own text.
* The step costs about 0.3 s for the default size (batch 8, context 64) on a Kirin 990; `medium` costs seconds.
* More context, width or layers need more text or the model remembers it.

## Exercises
1. Train on a page of your own writing and print what it writes with `temperature` 0.5 and 1.0.
2. Find the context length at which a one-layer model stops getting better on the sentence above.
3. Train two models, one for Thai and one for English text, and compare their `check` losses.

**Next:** lesson 4 (attention and convolution), `<llama>` (run big models).
