# Exam 2 Topics

Everything from Exam 1, plus:

## Data structure concepts and skills

  - abstract data types
      - understanding the difference between interface and
        implementation
      - reasoning in terms of the abstract interface
      - understanding what it means for implementation/representation to
        implement/represent the abstract operations/values

  - asymptotic complexity
      - working with big-O notation (simplification rules)
      - deriving big-O informally from implementation or pseudocode
      - simple amortization à la dynamic arrays (basically, understand
        what it means to say that dynamic array operations are amortized
        O(1), and why)

## Data structures

  - FIFO queue ADT
      - linked list implementation (and its complexity)
      - ring buffer implementation (and its complexity)

  - priority queue ADT
      - binary heap implementation
          - how array maps to complete tree
          - how the operations work
          - complexity

  - binary search trees
      - why balance is important
      - complexity of operations
      - what a tree rotation is (and what invariant it preserves)
      - you DO NOT need to know the details of AVL tree operations and
        rebalancing

  - disjoint sets ADT
      - weight-balanced path-compressing union-find implementation
          - how array represents a forest of parent-pointer trees
          - how the operations work
          - complexity

  - hash tables
      - purpose (implementing dictionary ADT)
      - general structure
          - separate chaining, vs.
          - linear probing
      - hash functions
          - what's it for?
          - what makes a hash function good?
      - complexity
          - expected (average case)
          - how it can degenerate to worst-case complexity

  - graphs
      - kinds
          - directed versus not
          - weighted versus not
      - representations:
          - adjacency lists
          - adjacency matrix
          - time and space complexities for each
      - depth- and breadth-first search

