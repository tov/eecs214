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

1.  ````
    |
    3
    ' '
    ````

2.  ````
    |
    2
    'c'
    ````

3.  ````
    |
    3
    'd'
    ````

4.  ````
    |
    6
    'e'
    ````

5.  ````
    |
    1
    'g'
    ````

6.  ````
    |
    1
    'h'
    ````

7.  ````
    |
    3
    'i'
    ````

8.  ````
    |
    1
    'l'
    ````

9.  ````
    |
    2
    'm'
    ````

10. ````
    |
    2
    'n'
    ````

11. ````
    |
    2
    'o'
    ````

12. ````
    |
    1
    'p'
    ````

13. ````
    |
    1
    'r'
    ````

14. ````
    |
    2
    't'
    ````

15. ````
    |
    1
    'w'
    ````

16. ````
    |
    1
    'x'
    ````

17. ````
    |
    1
    'z'
    ````

