# Huffman trees

## From last time: prefix codes

### Decoding

### Encoding

How to find the leaf of a symbol:

    FindLeaf(tree, label):
        let todo = {tree}  -- a singleton set

        while todo != ∅ do:
            node <- remove a node from todo

            if node is a leaf:
                if node.label = label then return Success(node)
            else:
                add node.left and node.right to todo

        return failure

    FindPath(tree, label):
        let todo = { (tree, ε) }  -- a singleton set

        while todo != ∅ do:
            (node, path) <- remove an element from todo

            if node is a leaf:
                if node.label = label then return Success(path)
            else:
                add (node.left, path ∘ 0) to todo
                add (node.right, path ∘ 1) to todo

        return failure


  - keep an table mapping symbols to their nodes (e.g., a 256 element
    array mapping characters to their nodes)

    table[256]: array of node pointers
    table['a'] = pointer to node labeled by 'a'
    table['b'] = pointer to node labeled by 'b'
    ...

    (or just put the codewords in the table.)

  - put parent links in nodes
      - traverse up the tree
      - output the bits in reverse order that you see them

## Constructing a Huffman tree

"this is a chocolate huffman tree"
