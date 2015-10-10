# Huffman trees

### What they are

A *prefix code tree* is a binary tree with:

  - leaves labeled by input symbols

  - edges labeled by output symbols

  - the edges along a path to an input symbol give its codeword in
    output symbols

A *Huffman tree* has the same form as a prefix code tree, except:

  - node (both leaves and internal nodes) is labeled by a "weight"
    giving the relative frequency of input symbols in that subtree

  - it is constructed according to Huffman's algorithm (described below)

Any prefix code tree will give a valid prefix code, but a Huffman tree
is optimal in a particular way: given some model of the frequency of
input symbols, it minimizes the expected (i.e., average) codeword
length.

### Decoding

To decode bits from the input stream:

  - Start at the root of the tree

  - While not at a leaf, read a bit, and follow the corresponding
    branch

  - Upon reaching a leaf, output that symbol and start at the root
    again.

### Encoding

How to find the leaf of a symbol:

    algorithm FindLeaf(tree, label):
        let todo = { tree }     -- set of nodes to visit

        while todo ≠ ∅:
            node ← remove an element from todo

            if node is a leaf:
                if node.label = label then return Success(node)
            else:
                add node.left and node.right to todo

        return failure

We can construct the codeword for a symbol as part of the search:

    algorithm FindPath(tree, label):
        -- set of nodes, each paired with its path:
        let todo = { (tree, ε) }

        while todo != ∅ do:
            (node, path) <- remove an element from todo

            if node is a leaf:
                if node.label = label then return Success(path)
            else:
                add (node.left, path ∘ 0) to todo
                add (node.right, path ∘ 1) to todo

        return Failure

However, the traversal potentially requires exploring the whole tree
once for each input symbol.

Optimizations:

  - To avoid the traversal, keep a table mapping symbols to their nodes.

    Example: a 256 element array mapping 8-bit chars to their nodes

        table[256]: array of node pointers

        ...
        table['a'] = pointer to node labeled by 'a'
        table['b'] = pointer to node labeled by 'b'
        ...

  - To find out the codeword of a node you have a reference to:

      - In each tree node include a link to the parent node:

            struct Branch {
                Tree *left, *right;
                Branch *parent;
            }

      - Traverse from leaf to root by following parent links

      - The traversed edges give the codeword in reverse

  - Or avoid all of the above by performing just one traversal and
    caching codewords in a table. (FindPath can be modified to construct
    such a table.

## Constructing a Huffman tree

First you need a *model*: some idea of the distribution of input
symbols. This can be:

  - probabilities of symbols appearing in the message (based on knowledge
    of the domain),

  - actual counts of symbols in the message,

  - or some kind of approximate counts.

We will construct the tree bottom up, starting with a forest (collection
of trees) in which every tree is a leaf. For each input symbol, create a
leaf node whose weight is its frequency according to the model. Then
find the two trees with the least weight and join them into a new tree,
where the weight of the new branch is the sum of the weights of its
subtrees. Repeat this with two smallest remaining trees until there is
only one tree remaining.

### Example

input message = "minimize expected codeword length"

letter frequencies =
  [(' ', 3); ('c', 2); ('d', 3); ('e', 6); ('g', 1); ('h', 1); ('i', 3);
  ('l', 1); ('m', 2); ('n', 2); ('o', 2); ('p', 1); ('r', 1); ('t', 2);
  ('w', 1); ('x', 1); ('z', 1)]

now we make a forest by turning each letter and its frequency into a
single-leaf tree. so this is our initial forest:

    [1]     |
            3
            ' '

    [2]     |
            2
            'c'

    [3]     |
            3
            'd'

    [4]     |
            6
            'e'

    [5]     |
            1
            'g'

    [6]     |
            1
            'h'

    [7]     |
            3
            'i'

    [8]     |
            1
            'l'

    [9]     |
            2
            'm'

    [10]    |
            2
            'n'

    [11]    |
            2
            'o'

    [12]    |
            1
            'p'

    [13]    |
            1
            'r'

    [14]    |
            2
            't'

    [15]    |
            1
            'w'

    [16]    |
            1
            'x'

    [17]    |
            1
            'z'

I've numbered the trees to make them easier to refer to. There are
several leaves whose weight is 1: 5, 6, 8, 12, 13, 15, 16, 17.  We
choose two of these, 5 and 6, to remove from the forest and combine into
a larger tree having weight 2:

    [18]      |
            +-2--+
            |    |
            1    1
            'g'  'h'

Then we repeat. Trees 8 and 12 have weight 1, so we combine them;
similarly 13 with 15 and 16 with 17. (The order doesn't matter, though
if we want to construct the same tree more than once from the same model
then it needs to be deterministic.) Here is our forest at this
point:

    [1]     |
            3
            ' '

    [2]     |
            2
            'c'

    [3]     |
            3
            'd'

    [4]     |
            6
            'e'

    [7]     |
            3
            'i'

    [9]     |
            2
            'm'

    [10]    |
            2
            'n'

    [11]    |
            2
            'o'

    [14]    |
            2
            't'

    [18]      |
            +-2--+
            |    |
            1    1
            'g'  'h'

    [19]      |
            +-2--+
            |    |
            1    1
            'l'  'p'

    [20]      |
            +-2--+
            |    |
            1    1
            'r'  'w'

    [21]      |
            +-2--+
            |    |
            1    1
            'x'  'z'

Now no trees of weight 1 remain, so we begin combining trees of weight
2.  Let's combine 21 with 20:

    [22]       |
          +----4----+
          |         |
        +-2--+    +-2--+
        |    |    |    |
        1    1    1    1
        'x'  'z'  'r'  'w'

Similarly, we'll combine weight-2 trees 2 with 9, 10 with 11, and 14
with 18, yielding:

    [23]      |
            +-4--+
            |    |
            2    2
            'c'  'm'

    [24]      |
            +-4--+
            |    |
            2    2
            'n'  'o'

    [25]       |
            +--4---+
            |      |
            2    +-2--+
            't'  |    |
                 1    1
                 'g'  'h'

Now we have only one tree of weight 2 remaining, so we cannot combine it
with another of weight 2. However, we have three trees of weight three,
so we will combine tree 19 (weight 2) with tree 1 (weight 3):

    [26]      |
          +---5---+
          |       |
        +-2--+    3
        |    |    ' '
        1    1
        'l'  'p'

Trees 3 and 7 both have weight 3, so we combine them:

    [27]      |
            +-6--+
            |    |
            3    3
            'd'  'i'

No trees of weight 3 remain, but trees 22, 23, 24, and 25 have weight 4,
so we combine 22 with 23 and 24 with 25. Next up, tree 26 has weight 5,
and trees 4 and 27 have weight 6. So we combine tree 26 with tree 27.
Now our forest comprises four trees:

    [4]     |
            6
            'e'

    [28]                  |
                   +------8-------+
                   |              |
              +----4----+       +-4--+
              |         |       |    |
            +-2--+    +-2--+    2    2
            |    |    |    |    'c'  'm'
            1    1    1    1
            'x'  'z'  'r'  'w'

    [29]           |
              +----8-----+
              |          |
            +-4--+    +--4---+
            |    |    |      |
            2    2    2    +-2--+
            'n'  'o'  't'  |    |
                           1    1
                           'g'  'h'

    [30]               |
                  +----11----+
                  |          |
              +---5---+    +-6--+
              |       |    |    |
            +-2--+    3    3    3
            |    |    ' '  'd'  'i'
            1    1
            'l'  'p'

Combining the lightest tree, tree 4 (weight 6) with one of the next
lightest trees, tree 28 (weight 8) yields a tree of weight 14:

    [31]             |
            +--------14--------+
            |                  |
            6           +------8-------+
            'e'         |              |
                   +----4----+       +-4--+
                   |         |       |    |
                 +-2--+    +-2--+    2    2
                 |    |    |    |    'c'  'm'
                 1    1    1    1
                 'x'  'z'  'r'  'w'

Now the lighest two trees are tree 29 (weight 8) and tree 30 (weight
11), so we combine these:

    [32]                         |
                   +-------------19-------------+
                   |                            |
              +----8-----+                 +----11----+
              |          |                 |          |
            +-4--+    +--4---+         +---5---+    +-6--+
            |    |    |      |         |       |    |    |
            2    2    2    +-2--+    +-2--+    3    3    3
            'n'  'o'  't'  |    |    |    |    ' '  'd'  'i'
                           1    1    1    1
                           'g'  'h'  'l'  'p'

Finally, we combine the two remaining trees, trees 31 and 32, to get our
Huffman tree:

````
                             |
       +---------------------33----------------------+
       |                                             |
+------14-------+                      +-------------19-------------+
|               |                      |                            |
6        +------8-------+         +----8-----+                 +----11----+
'e'      |              |         |          |                 |          |
    +----4----+       +-4--+    +-4--+    +--4---+         +---5---+    +-6--+
    |         |       |    |    |    |    |      |         |       |    |    |
  +-2--+    +-2--+    2    2    2    2    2    +-2--+    +-2--+    3    3    3
  |    |    |    |    'c'  'm'  'n'  'o'  't'  |    |    |    |    ' '  'd'  'i'
  1    1    1    1                             1    1    1    1
  'x'  'z'  'r'  'w'                           'g'  'h'  'l'  'p'
````

How much space will encoding with this Huffman tree save us?

  - The message is 33 characters long, so if we stored it in the
    conventional way, 8 bits/character, it would take 8 × 33 = **264 bits**.

  - The message uses 17 different symbols, which means that 5 bits per
    symbol is sufficient for a block code. (Five bits lets us encode 32
    different cases.) So at that rate, it would take 5 × 33 = **165 bits**.

  - To determine the number of bits required by the Huffman code, we can
    add up the weights of all the nodes except the root. (Can you see
    why? The weight on each node tells us how many times we will pass
    through that node while encoding the message...) Using the Huffman
    code, our message requires **128 bits**.

Of course, this doesn't include the overhead of transmitting the Huffman
tree itself, which is necessary to decode the message. In a real system,
we would need to communicate that information somehow, by encoding
either a representation of the tree itself or the frequency table so
that the decoder can rebuild the tree. Thus, for a short enough message,
the header overhead may overwhelm any savings due to the encoding.
