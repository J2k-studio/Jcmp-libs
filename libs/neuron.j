// neuron 0.5.0 -- tensors and small neural networks that train on the phone.   #import <neuron>   (needs jcmp 1.1.0.0; license: MPL-2.0)
// 0.2.0: Tensor::matmul_fast(o): float32 + NEON dot products + threads for big tables (see the fast way below)
//   Tensor a = Tensor::zeros(2, 3);   a.set(0, 1, 5.0);   Tensor c = a.matmul(b);   Tensor p = c.relu().softmax();
//   Network n = Network::make();   n.add(2, 8);   n.add(8, 1);                // layers of neurons: relu between them
//   n.fit(x, y, 3000, 0.1);   Tensor out = n.predict(x);   n.save("m.jw");   Network m = Network::load("m.jw");
// A Tensor is a table of rows x cols numbers (double); the methods return new Tensors. The file .jw is a text file (the weights).

#import <simd>
#import <cpu>
using cpu::thread;

// ---- the fast way to multiply (neuron 0.2.0): the numbers are packed as float32 in rows of a multiple of 8, B is turned over so that every
// result is a dot product of two rows (4 numbers at a time, no splat, two accumulators), and the rows of the result are shared among threads.
// bench/dot.jk measured: 1.8-2.1 GFLOPS on one core (the plain loop: 0.4), and about 3.5 times more with 4 threads.
float^ mm_a;                     // m rows of kp numbers
float^ mm_bt;                    // n rows of kp numbers (B turned over)
float^ mm_c;                     // m rows of n numbers
int mm_kp;
int mm_n;
int^ mm_range;                   // [2 * t] first row and [2 * t + 1] end row of the thread t

void mm_rows(void^ arg) {
    int id = (int)arg;
    float^ a = mm_a;
    float^ bt = mm_bt;
    float^ c = mm_c;
    int kp = mm_kp;
    int n = mm_n;
    for i in mm_range[2 * id]..mm_range[2 * id + 1] {
        for jj in 0..n {
            f32x4 s0 = {0.0, 0.0, 0.0, 0.0};
            f32x4 s1 = {0.0, 0.0, 0.0, 0.0};
            int k = 0;
            while k < kp {
                f32x4 a0 = f32x4::load(a, i * kp + k);
                f32x4 b0 = f32x4::load(bt, jj * kp + k);
                f32x4 a1 = f32x4::load(a, i * kp + k + 4);
                f32x4 b1 = f32x4::load(bt, jj * kp + k + 4);
                s0 = s0 + a0 * b0;
                s1 = s1 + a1 * b1;
                k += 8;
            }
            f32x4 s = s0 + s1;
            c[i * n + jj] = s.sum();
        }
    }
}

struct Tensor {
    int rows;
    int cols;
    double[] d;

    static Tensor zeros(int rows, int cols) {
        Tensor t;
        t.rows = rows;
        t.cols = cols;
        t.d = arr(rows * cols + 1);
        for i in 0..rows * cols { t.d.push(0.0); }
        return t;
    }
    double get(self, int r, int c) { return self.d[r * self.cols + c]; }
    void set(self, int r, int c, double v) { self.d[r * self.cols + c] = v; }

    Tensor matmul(self, Tensor o) {
        Tensor r = Tensor::zeros(self.rows, o.cols);
        for i in 0..self.rows {
            for k in 0..self.cols {
                double a = self.d[i * self.cols + k];
                for j in 0..o.cols { r.d[i * o.cols + j] += a * o.d[k * o.cols + j]; }
            }
        }
        return r;
    }
    // the same as matmul, much faster for big tables (pack to float32, dot products, threads); the numbers are float32 inside, so the last digits differ
    Tensor matmul_fast(self, Tensor o) {
        int m = self.rows;
        int k = self.cols;
        int n = o.cols;
        if m * k * n < 32768 { return self.matmul(o); }                // small: the plain loop is cheaper than the packing
        int kp = (k + 7) / 8 * 8;
        int sa = m * kp * 4 + 64;                                        // the buffers come from the system (mmap, zeroed): the compiler does not track them as owners
        int sb = n * kp * 4 + 64;
        int sc = m * n * 4 + 64;
        float^ pa = (float^)Sys::mmap(sa);
        float^ pbt = (float^)Sys::mmap(sb);
        float^ pc = (float^)Sys::mmap(sc);
        for i in 0..m { for kk in 0..kp { pa[i * kp + kk] = 0.0; if kk < k { pa[i * kp + kk] = (float)self.d[i * k + kk]; } } }
        for jj in 0..n { for kk in 0..kp { pbt[jj * kp + kk] = 0.0; if kk < k { pbt[jj * kp + kk] = (float)o.d[kk * n + jj]; } } }
        int threads = 4;
        if m < 16 { threads = 1; }
        mm_a = pa; mm_bt = pbt; mm_c = pc; mm_kp = kp; mm_n = n;
        int^ rng = (int^)Sys::mmap(4096);
        mm_range = rng;
        for t in 0..threads { rng[2 * t] = m * t / threads; rng[2 * t + 1] = m * (t + 1) / threads; }
        if threads == 1 { mm_rows((void^)0); }
        else {
            Thread[] ts = arr(4);
            for t in 0..threads { ts.push(create(mm_rows, (void^)t)); }
            for t in 0..threads { ts[t].join(); }
        }
        Sys::munmap((void^)rng, 4096);
        Tensor r = Tensor::zeros(m, n);
        for i in 0..m * n { r.d[i] = (double)pc[i]; }
        Sys::munmap((void^)pa, sa);
        Sys::munmap((void^)pbt, sb);
        Sys::munmap((void^)pc, sc);
        return r;
    }
    Tensor add(self, Tensor o) {                     // o may be one row: it is added to every row (the bias)
        Tensor r = Tensor::zeros(self.rows, self.cols);
        for i in 0..self.rows {
            for j in 0..self.cols {
                double b = o.d[j];
                if o.rows == self.rows { b = o.d[i * self.cols + j]; }
                r.d[i * self.cols + j] = self.d[i * self.cols + j] + b;
            }
        }
        return r;
    }
    Tensor transpose(self) {
        Tensor r = Tensor::zeros(self.cols, self.rows);
        for i in 0..self.rows { for j in 0..self.cols { r.d[j * self.rows + i] = self.d[i * self.cols + j]; } }
        return r;
    }
    Tensor relu(self) {
        Tensor r = Tensor::zeros(self.rows, self.cols);
        for i in 0..self.rows * self.cols { if self.d[i] > 0.0 { r.d[i] = self.d[i]; } }
        return r;
    }
    Tensor softmax(self) {                           // every row becomes numbers that sum to 1
        Tensor r = Tensor::zeros(self.rows, self.cols);
        for i in 0..self.rows {
            double m = self.d[i * self.cols];
            for j in 0..self.cols { if self.d[i * self.cols + j] > m { m = self.d[i * self.cols + j]; } }
            double s = 0.0;
            for j in 0..self.cols {
                double e = Math::exp(self.d[i * self.cols + j] - m);
                r.d[i * self.cols + j] = e;
                s += e;
            }
            for j in 0..self.cols { r.d[i * self.cols + j] = r.d[i * self.cols + j] / s; }
        }
        return r;
    }
}

// A layer of neurons: y = x @ w + b. forward() remembers x; backward() learns (plain gradient descent) and gives the gradient for the layer before.
struct Dense {
    Tensor w;
    Tensor b;
    Tensor x;

    static Dense make(int inputs, int outputs, int seed) {
        Dense l;
        l.w = Tensor::zeros(inputs, outputs);
        l.b = Tensor::zeros(1, outputs);
        int s = seed * 2654435761 + 12345;
        for i in 0..inputs * outputs {
            s = (s * 1103515245 + 12345) & 2147483647;
            l.w.d[i] = ((double)(s % 2000) / 1000.0 - 1.0) * Math::sqrt(2.0 / (double)inputs);
        }
        l.x = Tensor::zeros(1, 1);
        return l;
    }
    Tensor forward(self, Tensor x) {
        self.x = x;
        return x.matmul_fast(self.w).add(self.b);
    }
    Tensor backward(self, Tensor dy, double rate) {
        Tensor dx = dy.matmul_fast(self.w.transpose());
        Tensor dw = self.x.transpose().matmul_fast(dy);
        for i in 0..self.w.rows * self.w.cols { self.w.d[i] = self.w.d[i] - rate * dw.d[i]; }
        for j in 0..self.b.cols {
            double g = 0.0;
            for i in 0..dy.rows { g += dy.d[i * dy.cols + j]; }
            self.b.d[j] = self.b.d[j] - rate * g;
        }
        return dx;
    }
}

// A network of layers: every layer is Dense, with relu after all of them but the last. Trained by gradient descent on the mean squared error.
struct Network {
    Dense[] layers;
    int count;
    int seed;

    static Network make() {
        Network n;
        n.layers = arr(4);
        n.count = 0;
        n.seed = 1;
        return n;
    }
    void add(self, int inputs, int outputs) {
        self.seed += 1;
        self.layers.push(Dense::make(inputs, outputs, self.seed));
        self.count += 1;
    }
    Tensor predict(self, Tensor x) {
        Tensor h = x;
        for k in 0..self.count {
            h = self.layers[k].forward(h);
            if k < self.count - 1 { h = h.relu(); }
        }
        return h;
    }
    // one round over all the rows: returns the mean squared error before the step
    double step(self, Tensor x, Tensor y, double rate) {
        Tensor[] outs = arr(self.count + 1);
        Tensor h = x;
        for k in 0..self.count {
            h = self.layers[k].forward(h);
            outs.push(h);
            if k < self.count - 1 { h = h.relu(); }
        }
        Tensor o = outs[self.count - 1];
        Tensor g = Tensor::zeros(o.rows, o.cols);
        double loss = 0.0;
        int cells = o.rows * o.cols;
        for i in 0..cells {
            double d = o.d[i] - y.d[i];
            loss += d * d;
            g.d[i] = 2.0 * d / (double)cells;
        }
        int k2 = self.count - 1;
        while k2 >= 0 {
            Tensor gin = self.layers[k2].backward(g, rate);
            if k2 > 0 {
                Tensor pre = outs[k2 - 1];
                for i in 0..pre.rows * pre.cols { if pre.d[i] <= 0.0 { gin.d[i] = 0.0; } }
            }
            g = gin;
            k2 -= 1;
        }
        return loss / (double)cells;
    }
    double fit(self, Tensor x, Tensor y, int rounds, double rate) {
        double loss = 0.0;
        for e in 0..rounds { loss = self.step(x, y, rate); }
        return loss;
    }
    // the weights as text:  neuron-jw 1 / layers N / for each layer: inputs outputs and the numbers
    String text(self) {
        String t = "neuron-jw 1\nlayers " + str(self.count) + "\n";
        for k in 0..self.count {
            Dense l = self.layers[k];
            t = t + str(l.w.rows) + " " + str(l.w.cols) + "\n";
            for i in 0..l.w.rows * l.w.cols { t = t + str(l.w.d[i]) + " "; }
            t = t + "\n";
            for i in 0..l.b.cols { t = t + str(l.b.d[i]) + " "; }
            t = t + "\n";
        }
        return t;
    }
    bool save(self, String path) {
        Result<int, Error> r = Fs::write_text(path, self.text());
        return r.is_ok();
    }
    static Network load(String path) {
        Network n = Network::make();
        Result<String, Error> r = Fs::read_text(path);
        if !r.is_ok() { return n; }
        String[] ls = r.take().split("\n");
        if ls.len < 2 || ls[0] != "neuron-jw 1" { return n; }
        int count = ls[1].slice(7, ls[1].len).to_int();
        int at = 2;
        for k in 0..count {
            String[] dim = ls[at].split(" ");
            Dense l = Dense::make(dim[0].to_int(), dim[1].to_int(), 1);
            String[] wv = ls[at + 1].split(" ");
            for i in 0..l.w.rows * l.w.cols { l.w.d[i] = wv[i].to_double(); }
            String[] bv = ls[at + 2].split(" ");
            for i in 0..l.b.cols { l.b.d[i] = bv[i].to_double(); }
            n.layers.push(l);
            n.count += 1;
            at += 3;
        }
        return n;
    }
}

// ============================================================================================================================
// neuron 0.5.0: Tensor32 (float32, up to 4 dimensions) and Graph (autograd with a tape). The old Tensor / Network above stay as they are.
//   Graph g = Graph::make();
//   int w = g.param(Tensor32::random(2, 8, 1, 0.5));   int b = g.param(Tensor32::zeros(1, 8));      // parameters live as long as the graph
//   g.mark();                                                                                      // everything made after mark() is one step
//   for step in 0..1000 {
//       int x = g.input(xs);   int h = g.relu(g.add(g.matmul(x, w), b));   int loss = g.mse(h, ys);
//       g.backward(loss);   g.sgd(0.1);   g.clear();                                                // clear() throws the step away, keeps the parameters
//   }
// A node is an int (its number). g.value(n) is the Tensor32 of a node, g.grad(n) its gradient after backward.
// ============================================================================================================================

struct Tensor32 {
    int[] shape;                       // 1 to 4 numbers, the last one is the width of a row
    float[] d;

    static Tensor32 make(int[] shape) {
        Tensor32 t;
        t.shape = arr(shape.len + 1);                  // a copy: assigning the array would move it out of the caller's tensor
        int n = 1;
        for i in 0..shape.len { t.shape.push(shape[i]); n = n * shape[i]; }
        t.d = arr(n + 1);
        for i in 0..n { t.d.push(0.0); }
        return t;
    }
    static Tensor32 zeros(int rows, int cols) {
        int[] s = arr(2);
        s.push(rows);
        s.push(cols);
        return Tensor32::make(s);
    }
    // numbers from -scale to scale (a small generator with the seed: the same seed gives the same numbers)
    static Tensor32 random(int rows, int cols, int seed, double scale) {
        Tensor32 t = Tensor32::zeros(rows, cols);
        int s = seed * 2654435761 + 12345;
        for i in 0..rows * cols {
            s = (s * 1103515245 + 12345) & 2147483647;
            t.d[i] = (float)(((double)(s % 2000) / 1000.0 - 1.0) * scale);
        }
        return t;
    }
    // from a flat list of numbers, row by row
    static Tensor32 from_list(int rows, int cols, double[] v) {
        Tensor32 t = Tensor32::zeros(rows, cols);
        for i in 0..rows * cols { t.d[i] = (float)v[i]; }
        return t;
    }
    int size(self) { return self.d.len; }
    int cols(self) { return self.shape[self.shape.len - 1]; }
    int rows(self) { return self.d.len / self.shape[self.shape.len - 1]; }
    double get(self, int r, int c) { return (double)self.d[r * self.cols() + c]; }
    void set(self, int r, int c, double v) { self.d[r * self.cols() + c] = (float)v; }
    // the rows idx[0], idx[1], ... as a new table (a mini-batch)
    Tensor32 gather(self, int[] idx) {
        int c = self.cols();
        Tensor32 r = Tensor32::zeros(idx.len, c);
        for i in 0..idx.len { for j in 0..c { r.d[i * c + j] = self.d[idx[i] * c + j]; } }
        return r;
    }
    Tensor32 copy(self) {
        Tensor32 t = Tensor32::make(self.shape);
        for i in 0..self.d.len { t.d[i] = self.d[i]; }
        return t;
    }
    // the same numbers with another shape (the product must stay the same; a copy)
    Tensor32 reshape(self, int[] shape) {
        Tensor32 t = Tensor32::make(shape);
        for i in 0..self.d.len { t.d[i] = self.d[i]; }
        return t;
    }

    // a + b: the same shape, or b is one row that is added to every row (the bias)
    Tensor32 add(self, Tensor32 o) {
        Tensor32 r = Tensor32::make(self.shape);
        int c = self.cols();
        int n = self.d.len;
        if o.d.len == n { for i in 0..n { r.d[i] = self.d[i] + o.d[i]; } }
        else { for i in 0..n { r.d[i] = self.d[i] + o.d[i % c]; } }
        return r;
    }
    Tensor32 mul(self, Tensor32 o) {
        Tensor32 r = Tensor32::make(self.shape);
        for i in 0..self.d.len { r.d[i] = self.d[i] * o.d[i]; }
        return r;
    }
    Tensor32 scale(self, double k) {
        Tensor32 r = Tensor32::make(self.shape);
        float kf = (float)k;
        for i in 0..self.d.len { r.d[i] = self.d[i] * kf; }
        return r;
    }
    Tensor32 transpose(self) {
        int m = self.rows();
        int n = self.cols();
        Tensor32 r = Tensor32::zeros(n, m);
        for i in 0..m { for j in 0..n { r.d[j * m + i] = self.d[i * n + j]; } }
        return r;
    }
    Tensor32 relu(self) {
        Tensor32 r = Tensor32::make(self.shape);
        for i in 0..self.d.len { if self.d[i] > 0.0 { r.d[i] = self.d[i]; } }
        return r;
    }
    Tensor32 softmax(self) {                           // every row becomes numbers that sum to 1
        Tensor32 r = Tensor32::make(self.shape);
        int c = self.cols();
        int m = self.rows();
        for i in 0..m {
            double mx = (double)self.d[i * c];
            for j in 0..c { if (double)self.d[i * c + j] > mx { mx = (double)self.d[i * c + j]; } }
            double s = 0.0;
            for j in 0..c {
                double e = Math::exp((double)self.d[i * c + j] - mx);
                r.d[i * c + j] = (float)e;
                s += e;
            }
            for j in 0..c { r.d[i * c + j] = (float)((double)r.d[i * c + j] / s); }
        }
        return r;
    }
    double sum(self) {
        double s = 0.0;
        for i in 0..self.d.len { s += (double)self.d[i]; }
        return s;
    }
    double mean(self) { return self.sum() / (double)self.d.len; }

    // a @ b. Small tables: three plain loops in the order i, k, j (the inner loop walks both rows). Big tables: packed, dot products, threads (as matmul_fast).
    Tensor32 matmul(self, Tensor32 o) {
        int m = self.rows();
        int k = self.cols();
        int n = o.cols();
        Tensor32 r = Tensor32::zeros(m, n);
        if m * k * n < 32768 {
            for i in 0..m {
                for kk in 0..k {
                    float a = self.d[i * k + kk];
                    for j in 0..n { r.d[i * n + j] += a * o.d[kk * n + j]; }
                }
            }
            return r;
        }
        int kp = (k + 7) / 8 * 8;
        int sa = m * kp * 4 + 64;
        int sb = n * kp * 4 + 64;
        int sc = m * n * 4 + 64;
        float^ pa = (float^)Sys::mmap(sa);
        float^ pbt = (float^)Sys::mmap(sb);
        float^ pc = (float^)Sys::mmap(sc);
        for i in 0..m { for kk in 0..k { pa[i * kp + kk] = self.d[i * k + kk]; } }
        for jj in 0..n { for kk in 0..k { pbt[jj * kp + kk] = o.d[kk * n + jj]; } }
        int threads = 4;
        if m < 16 { threads = 1; }
        mm_a = pa; mm_bt = pbt; mm_c = pc; mm_kp = kp; mm_n = n;
        int^ rng = (int^)Sys::mmap(4096);
        mm_range = rng;
        for t in 0..threads { rng[2 * t] = m * t / threads; rng[2 * t + 1] = m * (t + 1) / threads; }
        if threads == 1 { mm_rows((void^)0); }
        else {
            Thread[] ts = arr(4);
            for t in 0..threads { ts.push(create(mm_rows, (void^)t)); }
            for t in 0..threads { ts[t].join(); }
        }
        Sys::munmap((void^)rng, 4096);
        for i in 0..m * n { r.d[i] = pc[i]; }
        Sys::munmap((void^)pa, sa);
        Sys::munmap((void^)pbt, sb);
        Sys::munmap((void^)pc, sc);
        return r;
    }
}

// operations of the tape
int OP_INPUT() { return 0; }
int OP_PARAM() { return 1; }
int OP_MATMUL() { return 2; }
int OP_ADD() { return 3; }
int OP_MUL() { return 4; }
int OP_RELU() { return 5; }
int OP_TANH() { return 6; }
int OP_SIGMOID() { return 7; }
int OP_MSE() { return 8; }
int OP_SOFTMAX_CE() { return 9; }
int OP_EMBED() { return 10; }
int OP_GELU() { return 11; }
int OP_SILU() { return 12; }
int OP_LAYER_NORM() { return 13; }
int OP_RMS_NORM() { return 14; }
int OP_ATTENTION() { return 15; }

// the two parameters of a layer (node numbers of the graph that made it)
struct Linear {
    int w;
    int b;
}

struct Graph {
    Tensor32[] val;                    // the value of every node
    Tensor32[] grad;                   // its gradient (zeros until backward)
    int[] op;
    int[] pa;                          // the first parent (a node number, -1 for none)
    int[] pb;
    int[] pc;                          // the third parent (attention), -1 for none
    int[] iarg;                        // a number of the node (attention: the number of heads)
    int[] aux;                         // whole numbers of the nodes (class numbers, embedding ids), one run per node
    int[] aux_off;                     // where the run of a node starts in aux
    int aux_keep;                      // the length of aux at mark()
    Tensor32[] target;                 // the target table of an mse node, the probabilities of softmax_ce / attention, the normalised x of a norm
    Tensor32[] extra;                  // a second table of a node (the 1/sigma of every row of a norm)
    int count;                         // the nodes now
    int keep;                          // the nodes before mark(): the parameters
    Tensor32[] m;                      // AdamW: the first and second moments of every parameter (made at the first adamw call)
    Tensor32[] v;
    int steps;                         // AdamW steps done
    double b1t;                        // beta1 ^ steps
    double b2t;

    static Graph make() {
        Graph g;
        g.val = arr(64);
        g.grad = arr(64);
        g.op = arr(64);
        g.pa = arr(64);
        g.pb = arr(64);
        g.pc = arr(64);
        g.iarg = arr(64);
        g.aux = arr(64);
        g.aux_off = arr(64);
        g.aux_keep = 0;
        g.target = arr(64);
        g.extra = arr(64);
        g.count = 0;
        g.keep = 0;
        g.m = arr(4);
        g.v = arr(4);
        g.steps = 0;
        g.b1t = 1.0;
        g.b2t = 1.0;
        return g;
    }
    int node(self, int op, int a, int b, Tensor32 v) {
        self.val.push(v);
        self.grad.push(Tensor32::zeros(1, 1));
        self.op.push(op);
        self.pa.push(a);
        self.pb.push(b);
        self.pc.push(-1);
        self.iarg.push(0);
        self.aux_off.push(self.aux.len);
        self.target.push(Tensor32::zeros(1, 1));
        self.extra.push(Tensor32::zeros(1, 1));
        self.count += 1;
        return self.count - 1;
    }
    int input(self, Tensor32 t) { return self.node(OP_INPUT(), -1, -1, t); }
    int param(self, Tensor32 t) { return self.node(OP_PARAM(), -1, -1, t); }
    // the nodes made so far are the parameters; clear() goes back to this point
    void mark(self) { self.keep = self.count; self.aux_keep = self.aux.len; }
    void clear(self) {
        while self.count > self.keep {
            Tensor32 gone = self.val.pop();
            Tensor32 gone2 = self.grad.pop();
            self.op.pop();
            self.pa.pop();
            self.pb.pop();
            Tensor32 gone3 = self.target.pop();
            Tensor32 gone4 = self.extra.pop();
            self.pc.pop();
            self.iarg.pop();
            self.aux_off.pop();
            self.count -= 1;
        }
        while self.aux.len > self.aux_keep { self.aux.pop(); }
    }
    Tensor32 value(self, int n) { return self.val[n]; }
    Tensor32 gradient(self, int n) { return self.grad[n]; }

    int matmul(self, int a, int b) { return self.node(OP_MATMUL(), a, b, self.val[a].matmul(self.val[b])); }
    int add(self, int a, int b) { return self.node(OP_ADD(), a, b, self.val[a].add(self.val[b])); }
    int mul(self, int a, int b) { return self.node(OP_MUL(), a, b, self.val[a].mul(self.val[b])); }
    int relu(self, int a) { return self.node(OP_RELU(), a, -1, self.val[a].relu()); }
    int tanh(self, int a) {
        Tensor32 r = Tensor32::make(self.val[a].shape);
        for i in 0..r.d.len { r.d[i] = (float)Math::tanh((double)self.val[a].d[i]); }
        return self.node(OP_TANH(), a, -1, r);
    }
    int sigmoid(self, int a) {
        Tensor32 r = Tensor32::make(self.val[a].shape);
        for i in 0..r.d.len { r.d[i] = (float)(1.0 / (1.0 + Math::exp(0.0 - (double)self.val[a].d[i]))); }
        return self.node(OP_SIGMOID(), a, -1, r);
    }

    // rows of a table of vectors (token numbers -> vectors): ids has one number per row of the result; the table is a parameter of shape vocab x width
    int embed(self, int table, int[] ids) {
        int w = self.val[table].cols();
        Tensor32 r = Tensor32::zeros(ids.len, w);
        for i in 0..ids.len { for j in 0..w { r.d[i * w + j] = self.val[table].d[ids[i] * w + j]; } }
        int n = self.node(OP_EMBED(), table, -1, r);
        for i in 0..ids.len { self.aux.push(ids[i]); }
        self.iarg[n] = ids.len;
        return n;
    }
    // GELU (the tanh form) and SiLU (x times sigmoid x)
    int gelu(self, int a) {
        Tensor32 r = Tensor32::make(self.val[a].shape);
        for i in 0..r.d.len {
            double x = (double)self.val[a].d[i];
            r.d[i] = (float)(0.5 * x * (1.0 + Math::tanh(0.7978845608 * (x + 0.044715 * x * x * x))));
        }
        return self.node(OP_GELU(), a, -1, r);
    }
    int silu(self, int a) {
        Tensor32 r = Tensor32::make(self.val[a].shape);
        for i in 0..r.d.len {
            double x = (double)self.val[a].d[i];
            r.d[i] = (float)(x / (1.0 + Math::exp(0.0 - x)));
        }
        return self.node(OP_SILU(), a, -1, r);
    }
    // every row: (x - mean) / sqrt(variance + 0.00001), then times gain and plus bias (gain and bias: one row each, as parameters)
    int layer_norm(self, int a, int gain, int bias) {
        int c = self.val[a].cols();
        int m = self.val[a].rows();
        Tensor32 y = Tensor32::make(self.val[a].shape);
        Tensor32 xh = Tensor32::make(self.val[a].shape);
        Tensor32 inv = Tensor32::zeros(m, 1);
        for i in 0..m {
            double mu = 0.0;
            for j in 0..c { mu += (double)self.val[a].d[i * c + j]; }
            mu = mu / (double)c;
            double var = 0.0;
            for j in 0..c { double e = (double)self.val[a].d[i * c + j] - mu; var += e * e; }
            var = var / (double)c;
            double iv = 1.0 / Math::sqrt(var + 0.00001);
            inv.d[i] = (float)iv;
            for j in 0..c {
                double h = ((double)self.val[a].d[i * c + j] - mu) * iv;
                xh.d[i * c + j] = (float)h;
                y.d[i * c + j] = (float)(h * (double)self.val[gain].d[j] + (double)self.val[bias].d[j]);
            }
        }
        int n = self.node(OP_LAYER_NORM(), a, gain, y);
        self.pc[n] = bias;
        self.target[n] = xh;
        self.extra[n] = inv;
        return n;
    }
    // every row: x / sqrt(mean of squares + 0.00001), times gain (the norm of the Llama models: no mean, no bias)
    int rms_norm(self, int a, int gain) {
        int c = self.val[a].cols();
        int m = self.val[a].rows();
        Tensor32 y = Tensor32::make(self.val[a].shape);
        Tensor32 xh = Tensor32::make(self.val[a].shape);
        Tensor32 inv = Tensor32::zeros(m, 1);
        for i in 0..m {
            double ms = 0.0;
            for j in 0..c { double e = (double)self.val[a].d[i * c + j]; ms += e * e; }
            ms = ms / (double)c;
            double iv = 1.0 / Math::sqrt(ms + 0.00001);
            inv.d[i] = (float)iv;
            for j in 0..c {
                double h = (double)self.val[a].d[i * c + j] * iv;
                xh.d[i * c + j] = (float)h;
                y.d[i * c + j] = (float)(h * (double)self.val[gain].d[j]);
            }
        }
        int n = self.node(OP_RMS_NORM(), a, gain, y);
        self.target[n] = xh;
        self.extra[n] = inv;
        return n;
    }
    // causal self-attention of one sequence: q, k, v have one row per position and the width is split into `heads` equal parts;
    // position i looks at the positions 0..i only: softmax(q.k / sqrt(width of a head)) @ v
    int attention(self, int q, int k, int v, int heads) {
        int t = self.val[q].rows();
        int w = self.val[q].cols();
        int dh = w / heads;
        double sc = 1.0 / Math::sqrt((double)dh);
        Tensor32 out = Tensor32::zeros(t, w);
        Tensor32 pr = Tensor32::zeros(heads * t, t);
        for h in 0..heads {
            for i in 0..t {
                double mx = -1.0e30;
                for j in 0..i + 1 {
                    double s = 0.0;
                    for d in 0..dh { s += (double)self.val[q].d[i * w + h * dh + d] * (double)self.val[k].d[j * w + h * dh + d]; }
                    s = s * sc;
                    pr.d[(h * t + i) * t + j] = (float)s;
                    if s > mx { mx = s; }
                }
                double z = 0.0;
                for j in 0..i + 1 {
                    double e = Math::exp((double)pr.d[(h * t + i) * t + j] - mx);
                    pr.d[(h * t + i) * t + j] = (float)e;
                    z += e;
                }
                for j in 0..i + 1 {
                    double p = (double)pr.d[(h * t + i) * t + j] / z;
                    pr.d[(h * t + i) * t + j] = (float)p;
                    for d in 0..dh { out.d[i * w + h * dh + d] += (float)(p * (double)self.val[v].d[j * w + h * dh + d]); }
                }
            }
        }
        int n = self.node(OP_ATTENTION(), q, k, out);
        self.pc[n] = v;
        self.iarg[n] = heads;
        self.target[n] = pr;
        return n;
    }

    // the mean of the squares of (a - target): one number
    int mse(self, int a, Tensor32 target) {
        double s = 0.0;
        for i in 0..target.d.len {
            double e = (double)self.val[a].d[i] - (double)target.d[i];
            s += e * e;
        }
        Tensor32 r = Tensor32::zeros(1, 1);
        r.d[0] = (float)(s / (double)target.d.len);
        int n = self.node(OP_MSE(), a, -1, r);
        self.target[n] = target;
        return n;
    }
    // softmax of every row of a (the scores), then the mean of -log(probability of the right class); classes: one class number per row
    int softmax_ce(self, int a, int[] classes) {
        Tensor32 p = self.val[a].softmax();
        int c = p.cols();
        double s = 0.0;
        for i in 0..classes.len { s = s - Math::log((double)p.d[i * c + classes[i]] + 0.0000000001); }
        Tensor32 r = Tensor32::zeros(1, 1);
        r.d[0] = (float)(s / (double)classes.len);
        int n = self.node(OP_SOFTMAX_CE(), a, -1, r);
        for i in 0..classes.len { self.aux.push(classes[i]); }
        self.iarg[n] = classes.len;
        self.target[n] = p;
        return n;
    }

    // adds g to the gradient of node n
    void give(self, int n, Tensor32 g) {
        if self.grad[n].d.len != g.d.len { self.grad[n] = g.copy(); return; }
        for i in 0..g.d.len { self.grad[n].d[i] += g.d[i]; }
    }
    // the gradients of everything the node `loss` depends on (loss: a node with one number); the gradients of an earlier step are forgotten
    void backward(self, int loss) {
        for i in 0..self.count { self.grad[i] = Tensor32::zeros(1, 1); }
        Tensor32 one = Tensor32::zeros(1, 1);
        one.d[0] = 1.0;
        self.grad[loss] = one;
        int i = loss;
        while i >= 0 {
            if self.grad[i].d.len == self.val[i].d.len || self.op[i] == OP_MSE() || self.op[i] == OP_SOFTMAX_CE() {
                int o = self.op[i];
                int a = self.pa[i];
                int b = self.pb[i];
                Tensor32 dy = self.grad[i];
                if o == OP_MATMUL() {
                    self.give(a, dy.matmul(self.val[b].transpose()));
                    self.give(b, self.val[a].transpose().matmul(dy));
                } else if o == OP_ADD() {
                    self.give(a, dy);
                    if self.val[b].d.len == dy.d.len { self.give(b, dy); }
                    else {                                                 // the bias: the sum of the rows
                        int c = dy.cols();
                        Tensor32 gb = Tensor32::zeros(1, c);
                        for r in 0..dy.rows() { for j in 0..c { gb.d[j] += dy.d[r * c + j]; } }
                        self.give(b, gb);
                    }
                } else if o == OP_MUL() {
                    self.give(a, dy.mul(self.val[b]));
                    self.give(b, dy.mul(self.val[a]));
                } else if o == OP_RELU() {
                    Tensor32 g = Tensor32::make(dy.shape);
                    for k in 0..g.d.len { if self.val[a].d[k] > 0.0 { g.d[k] = dy.d[k]; } }
                    self.give(a, g);
                } else if o == OP_TANH() {
                    Tensor32 g = Tensor32::make(dy.shape);
                    for k in 0..g.d.len { g.d[k] = dy.d[k] * (1.0 - self.val[i].d[k] * self.val[i].d[k]); }
                    self.give(a, g);
                } else if o == OP_SIGMOID() {
                    Tensor32 g = Tensor32::make(dy.shape);
                    for k in 0..g.d.len { g.d[k] = dy.d[k] * self.val[i].d[k] * (1.0 - self.val[i].d[k]); }
                    self.give(a, g);
                } else if o == OP_MSE() {
                    Tensor32 g = Tensor32::make(self.val[a].shape);
                    float k2 = (float)(2.0 * (double)dy.d[0] / (double)g.d.len);
                    for k in 0..g.d.len { g.d[k] = (self.val[a].d[k] - self.target[i].d[k]) * k2; }
                    self.give(a, g);
                } else if o == OP_EMBED() {
                    int w = self.val[a].cols();
                    Tensor32 g = Tensor32::zeros(self.val[a].rows(), w);
                    for r in 0..self.iarg[i] {
                        int id = self.aux[self.aux_off[i] + r];
                        for j in 0..w { g.d[id * w + j] += dy.d[r * w + j]; }
                    }
                    self.give(a, g);
                } else if o == OP_GELU() {
                    Tensor32 g = Tensor32::make(dy.shape);
                    for k in 0..g.d.len {
                        double x = (double)self.val[a].d[k];
                        double u = 0.7978845608 * (x + 0.044715 * x * x * x);
                        double th = Math::tanh(u);
                        double du = 0.7978845608 * (1.0 + 3.0 * 0.044715 * x * x);
                        g.d[k] = (float)((double)dy.d[k] * (0.5 * (1.0 + th) + 0.5 * x * (1.0 - th * th) * du));
                    }
                    self.give(a, g);
                } else if o == OP_SILU() {
                    Tensor32 g = Tensor32::make(dy.shape);
                    for k in 0..g.d.len {
                        double x = (double)self.val[a].d[k];
                        double sg = 1.0 / (1.0 + Math::exp(0.0 - x));
                        g.d[k] = (float)((double)dy.d[k] * sg * (1.0 + x * (1.0 - sg)));
                    }
                    self.give(a, g);
                } else if o == OP_LAYER_NORM() || o == OP_RMS_NORM() {
                    int c = dy.cols();
                    int m = dy.rows();
                    Tensor32 dx = Tensor32::make(dy.shape);
                    Tensor32 dg = Tensor32::zeros(1, c);
                    Tensor32 db = Tensor32::zeros(1, c);
                    for r in 0..m {
                        double s1 = 0.0;
                        double s2 = 0.0;
                        for j in 0..c {
                            double dyj = (double)dy.d[r * c + j];
                            double xh = (double)self.target[i].d[r * c + j];
                            double dxh = dyj * (double)self.val[b].d[j];
                            s1 += dxh;
                            s2 += dxh * xh;
                            dg.d[j] += (float)(dyj * xh);
                            db.d[j] += (float)dyj;
                        }
                        double iv = (double)self.extra[i].d[r];
                        for j in 0..c {
                            double xh = (double)self.target[i].d[r * c + j];
                            double dxh = (double)dy.d[r * c + j] * (double)self.val[b].d[j];
                            if o == OP_LAYER_NORM() { dx.d[r * c + j] = (float)(iv * (dxh - s1 / (double)c - xh * s2 / (double)c)); }
                            else { dx.d[r * c + j] = (float)(iv * (dxh - xh * s2 / (double)c)); }
                        }
                    }
                    self.give(a, dx);
                    self.give(b, dg);
                    if o == OP_LAYER_NORM() { self.give(self.pc[i], db); }
                } else if o == OP_ATTENTION() {
                    int vv = self.pc[i];
                    int t = self.val[a].rows();
                    int w = self.val[a].cols();
                    int heads = self.iarg[i];
                    int dh = w / heads;
                    double sc = 1.0 / Math::sqrt((double)dh);
                    Tensor32 dq = Tensor32::zeros(t, w);
                    Tensor32 dk = Tensor32::zeros(t, w);
                    Tensor32 dv = Tensor32::zeros(t, w);
                    for h in 0..heads {
                        for r in 0..t {
                            double dot = 0.0;                                   // sum over j of P_rj * dP_rj
                            for j in 0..r + 1 {
                                double dp = 0.0;
                                for d in 0..dh { dp += (double)dy.d[r * w + h * dh + d] * (double)self.val[vv].d[j * w + h * dh + d]; }
                                dot += (double)self.target[i].d[(h * t + r) * t + j] * dp;
                            }
                            for j in 0..r + 1 {
                                double p = (double)self.target[i].d[(h * t + r) * t + j];
                                double dp = 0.0;
                                for d in 0..dh { dp += (double)dy.d[r * w + h * dh + d] * (double)self.val[vv].d[j * w + h * dh + d]; }
                                double ds = p * (dp - dot) * sc;
                                for d in 0..dh {
                                    dv.d[j * w + h * dh + d] += (float)(p * (double)dy.d[r * w + h * dh + d]);
                                    dq.d[r * w + h * dh + d] += (float)(ds * (double)self.val[b].d[j * w + h * dh + d]);
                                    dk.d[j * w + h * dh + d] += (float)(ds * (double)self.val[a].d[r * w + h * dh + d]);
                                }
                            }
                        }
                    }
                    self.give(a, dq);
                    self.give(b, dk);
                    self.give(vv, dv);
                } else if o == OP_SOFTMAX_CE() {
                    Tensor32 g = self.target[i].copy();                    // the probabilities
                    int c = g.cols();
                    int rows = self.iarg[i];
                    for r in 0..rows { g.d[r * c + self.aux[self.aux_off[i] + r]] -= 1.0; }
                    float k3 = (float)((double)dy.d[0] / (double)rows);
                    for k in 0..g.d.len { g.d[k] = g.d[k] * k3; }
                    self.give(a, g);
                }
            }
            i -= 1;
        }
    }

    // a layer: y = x @ w + b; the two parameters are made now (call it before mark())
    Linear linear(self, int inputs, int outputs, int seed) {
        Linear l;
        l.w = self.param(Tensor32::random(inputs, outputs, seed, Math::sqrt(3.0 / (double)inputs)));
        l.b = self.param(Tensor32::zeros(1, outputs));
        return l;
    }
    int apply(self, Linear l, int x) { return self.add(self.matmul(x, l.w), l.b); }

    // the size of the gradient of all parameters (the square root of the sum of squares); when it is above max_norm all gradients are made smaller so that it is max_norm
    double clip(self, double max_norm) {
        double sq = 0.0;
        for n in 0..self.keep {
            if self.op[n] == OP_PARAM() && self.grad[n].d.len == self.val[n].d.len {
                for k in 0..self.grad[n].d.len { sq += (double)self.grad[n].d[k] * (double)self.grad[n].d[k]; }
            }
        }
        double norm = Math::sqrt(sq);
        if norm > max_norm && norm > 0.0 {
            float f = (float)(max_norm / norm);
            for n in 0..self.keep {
                if self.op[n] == OP_PARAM() && self.grad[n].d.len == self.val[n].d.len {
                    for k in 0..self.grad[n].d.len { self.grad[n].d[k] = self.grad[n].d[k] * f; }
                }
            }
        }
        return norm;
    }

    // AdamW: the moving averages of the gradient and of its square (beta 0.9 and 0.999), and the weight decay that is taken from the weights themselves
    void adamw(self, double lr, double decay) {
        double beta1 = 0.9;
        double beta2 = 0.999;
        double eps = 0.00000001;
        while self.m.len < self.keep { self.m.push(Tensor32::zeros(1, 1)); self.v.push(Tensor32::zeros(1, 1)); }
        self.steps += 1;
        self.b1t = self.b1t * beta1;
        self.b2t = self.b2t * beta2;
        double c1 = 1.0 - self.b1t;
        double c2 = 1.0 - self.b2t;
        for n in 0..self.keep {
            if self.op[n] == OP_PARAM() && self.grad[n].d.len == self.val[n].d.len {
                if self.m[n].d.len != self.val[n].d.len { self.m[n] = Tensor32::make(self.val[n].shape); self.v[n] = Tensor32::make(self.val[n].shape); }
                for k in 0..self.val[n].d.len {
                    double gk = (double)self.grad[n].d[k];
                    double mk = beta1 * (double)self.m[n].d[k] + (1.0 - beta1) * gk;
                    double vk = beta2 * (double)self.v[n].d[k] + (1.0 - beta2) * gk * gk;
                    self.m[n].d[k] = (float)mk;
                    self.v[n].d[k] = (float)vk;
                    double w = (double)self.val[n].d[k];
                    w = w - lr * ((mk / c1) / (Math::sqrt(vk / c2) + eps) + decay * w);
                    self.val[n].d[k] = (float)w;
                }
            }
        }
    }

    // the parameters in a text file (numbers with 9 digits); load() puts them back into a graph that has the same parameters (same order and shapes)
    bool save(self, String path) {
        String t = "neuron-graph 1\n";
        int np = 0;
        for n in 0..self.keep { if self.op[n] == OP_PARAM() { np += 1; } }
        t.append("params " + str(np) + "\n");
        for n in 0..self.keep {
            if self.op[n] == OP_PARAM() {
                String line = "";
                for k in 0..self.val[n].shape.len { line.append(str(self.val[n].shape[k]) + " "); }
                t.append(line + "\n");
                String nums = "";
                for k in 0..self.val[n].d.len {
                    if k > 0 { nums.push(' '); }
                    nums.append(Json::num_text((double)self.val[n].d[k]));
                }
                t.append(nums + "\n");
            }
        }
        Result<int, Error> r = Fs::write_text(path, t);
        return r.is_ok();
    }
    bool load(self, String path) {
        Result<String, Error> r = Fs::read_text(path);
        if !r.is_ok() { return false; }
        String[] ls = r.take().split("\n");
        if ls.len < 2 || ls[0] != "neuron-graph 1" { return false; }
        int np = 0;
        for n in 0..self.keep { if self.op[n] == OP_PARAM() { np += 1; } }
        if ls[1] != "params " + str(np) { return false; }
        int at = 2;
        for n in 0..self.keep {
            if self.op[n] == OP_PARAM() {
                String want = "";
                for k in 0..self.val[n].shape.len { want.append(str(self.val[n].shape[k]) + " "); }
                if at + 1 >= ls.len || ls[at] != want { return false; }
                String[] nums = ls[at + 1].split(" ");
                if nums.len != self.val[n].d.len { return false; }
                for k in 0..nums.len { self.val[n].d[k] = (float)nums[k].to_double(); }
                at += 2;
            }
        }
        return true;
    }

    // plain gradient descent on the parameters (the first `keep` nodes that are parameters)
    void sgd(self, double rate) {
        float r = (float)rate;
        for n in 0..self.keep {
            if self.op[n] == OP_PARAM() && self.grad[n].d.len == self.val[n].d.len {
                for k in 0..self.val[n].d.len { self.val[n].d[k] -= r * self.grad[n].d[k]; }
            }
        }
    }
}

// the numbers 0 .. n-1 in a mixed order (the same seed gives the same order): for mini-batches
int[] shuffled(int n, int seed) {
    int[] a = arr(n + 1);
    for i in 0..n { a.push(i); }
    int s = seed * 2654435761 + 12345;
    int i = n - 1;
    while i > 0 {
        s = (s * 1103515245 + 12345) & 2147483647;
        int j = s % (i + 1);
        int t = a[i];
        a[i] = a[j];
        a[j] = t;
        i -= 1;
    }
    return a;
}

// learning-rate schedules: step from 0 to total
struct Sched {
    // grows from 0 to base in `warm` steps, then falls to low along a cosine until `total`
    static double cosine(int step, int total, int warm, double base, double low) {
        if step < warm { return base * (double)(step + 1) / (double)warm; }
        double p = (double)(step - warm) / (double)(total - warm);
        if p > 1.0 { p = 1.0; }
        return low + (base - low) * 0.5 * (1.0 + Math::cos(3.141592653589793 * p));
    }
}

