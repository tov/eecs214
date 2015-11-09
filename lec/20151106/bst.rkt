;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname bst) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t quasiquote repeating-decimal #t #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
;;
;; AVL Trees
;; EECS 214, November 6, 2015
;;

(define-struct leaf [])
(define-struct branch [left element right])

(define left branch-left)
(define element branch-element)
(define right branch-right)

; An [BinTree X] is one of:
; -- (leaf)
; -- (branch [BinTree X] X [BinTree X])
; Interpretation: a binary tree of Xs

; Some examples:
(define LEAF (make-leaf))
(define TREE-2 (make-branch LEAF 2 LEAF))
(define TREE-3 (make-branch LEAF 3 LEAF))
(define TREE-4 (make-branch LEAF 4 LEAF))
(define TREE-5 (make-branch LEAF 5 LEAF))
(define TREE-6 (make-branch LEAF 6 LEAF))
(define TREE-7 (make-branch LEAF 7 LEAF))
(define TREE-8 (make-branch LEAF 8 LEAF))
(define TREE-9 (make-branch LEAF 9 LEAF))
(define TREE-24 (make-branch LEAF 2 TREE-4))
(define TREE-42 (make-branch TREE-4 2 LEAF))
(define TREE-678 (make-branch TREE-6 7 TREE-8))
(define TREE-245678 (make-branch TREE-24 5 TREE-678))
(define TREE-425678 (make-branch TREE-42 5 TREE-678))

;;; Let’s add the BST property (and simplify to Integer instead of X)

; An IntBST is one of:
; -- (make-leaf)
; -- (make-branch IntBST Integer IntBST)
;
; Invariant: (int-bst? IntBST)

; int-bst? : [BinTree Integer] -> Boolean
; Does a binary tree of integers satisfy the BST property?
;
; Examples:
(check-expect (int-bst? LEAF) #true)
(check-expect (int-bst? TREE-4) #true)
(check-expect (int-bst? TREE-24) #true)
(check-expect (int-bst? TREE-42) #false)
(check-expect (int-bst? TREE-678) #true)
(check-expect (int-bst? TREE-245678) #true)
(check-expect (int-bst? TREE-425678) #false)
; Strategy: function composition
(define (int-bst? a-tree)
  (int-bst-within? -INF.0 a-tree +INF.0))

; Number IntBST Number -> Boolean
; Are all the elements of a-tree between left-bound and right-bound?
;
; ASSUMPTION: (< left-bound right-bound)
;
; Strategy: structural decomposition (IntBST) with two accumulators
; representing the least and greatest values present in the context. 
(define (int-bst-within? left-bound a-tree right-bound)
  (cond
    [(leaf? a-tree)  #true]
    [(branch? a-tree)
     (and
      (< left-bound (element a-tree) right-bound)
      (int-bst-within? left-bound (left a-tree) (element a-tree))
      (int-bst-within? (element a-tree) (right a-tree) right-bound))]))

;;; Now let’s abstract the element type:

; An [Ord X] is a function [X X -> Boolean]
; that describes a total order on Xs. That is, if lt? is an [Ord X], then
;  - for all Xs x, (not (lt? x x)) {anti-reflexivity}
;  - for all pairs of distinguishable Xs x and y, either (lt? x y) XOR
;    (lt? y x) {totality}
;  - for all Xs x, y, and z, if (lt? x y) and (lt? y z) then (lt? x z)
;    {transitivity}

; A [BST X] is one of:
; -- (make-leaf)
; -- (make-branch [BST X] X [BST X])

; Invariant: (bst? lt? [BST X]) for some total order lt? : [Ord x]

; [Ord X] [BinTree X] -> Boolean
; Does a binary tree satisfy the BST property?
;
; Examples:
(check-expect (bst? < LEAF) #true)
(check-expect (bst? < TREE-4) #true)
(check-expect (bst? < TREE-24) #true)
(check-expect (bst? < TREE-42) #false)
(check-expect (bst? < TREE-245678) #true)
(check-expect (bst? < TREE-425678) #false)

(check-expect (bst? > LEAF) #true)
(check-expect (bst? > TREE-4) #true)
(check-expect (bst? > TREE-24) #false)
(check-expect (bst? > TREE-42) #true)
(check-expect (bst? > TREE-245678) #false)
(check-expect (bst? > TREE-425678) #false)

; Strategy: function composition
(define (bst? lt? a-tree)
  (local
    [(define edge-marker (vector))
     (define (lt?* a b)
       (or (eq? edge-marker a)
           (eq? edge-marker b)
           (lt? a b)))]
    (bst-within? lt?* edge-marker a-tree edge-marker)))

; [Ord X] X [BST X] X -> Boolean
; Are all the elements of a-tree between left-bound and right-bound?
;
; Strategy: structural decomposition (BST) with two accumulators
; representing the least and greatest values present in the context. 
(define (bst-within? lt? left-bound a-tree right-bound)
  (cond
    [(leaf? a-tree)  #true]
    [(branch? a-tree)
     (and
      (lt? left-bound (element a-tree))
      (lt? (element a-tree) right-bound)
      (bst-within? lt? left-bound (left a-tree) (element a-tree))
      (bst-within? lt? (element a-tree) (right a-tree) right-bound))]))

; [Ord X] X [BST X] -> [Or X #false]
; Is needle an element of haystack?
; ASSUMPTION: (bst? lt? haystack)
(define (bst-lookup lt? needle haystack)
  (cond
    [(leaf? haystack) #false]
    [(lt? needle (element haystack))
     (bst-lookup lt? needle (left haystack))]
    [(lt? (element haystack) needle)
     (bst-lookup lt? needle (right haystack))]
    [else
     (element haystack)]))

(check-expect (bst-lookup < 3 LEAF) #false)
(check-expect (bst-lookup < 3 TREE-4) #false)
(check-expect (bst-lookup < 4 TREE-4) 4)
(check-expect (bst-lookup < 1 TREE-24) #false)
(check-expect (bst-lookup < 2 TREE-24) 2)
(check-expect (bst-lookup < 3 TREE-24) #false)
(check-expect (bst-lookup < 4 TREE-24) 4)
(check-expect (bst-lookup < 5 TREE-24) #false)
(check-expect (bst-lookup > 1 TREE-42) #false)
(check-expect (bst-lookup > 2 TREE-42) 2)
(check-expect (bst-lookup > 3 TREE-42) #false)
(check-expect (bst-lookup > 4 TREE-42) 4)
(check-expect (bst-lookup > 5 TREE-42) #false)
(check-expect (bst-lookup < 1 TREE-245678) #false)
(check-expect (bst-lookup < 2 TREE-245678) 2)
(check-expect (bst-lookup < 3 TREE-245678) #false)
(check-expect (bst-lookup < 4 TREE-245678) 4)
(check-expect (bst-lookup < 5 TREE-245678) 5)
(check-expect (bst-lookup < 6 TREE-245678) 6)
(check-expect (bst-lookup < 7 TREE-245678) 7)
(check-expect (bst-lookup < 8 TREE-245678) 8)
(check-expect (bst-lookup < 9 TREE-245678) #false)


; [Ord X] X [BST X] -> [BST X]
; Add element new to tree.
; ASSUMPTION: (bst? lt? tree)
(define (bst-insert lt? new tree)
  (cond
    [(leaf? tree) (make-branch LEAF new LEAF)]
    [(lt? new (element tree))
     (make-branch
      (bst-insert lt? new (left tree))
      (element tree)
      (right tree))]  
    [(lt? (element tree) new)
     (make-branch
      (left tree)
      (element tree)
      (bst-insert lt? new (right tree)))]
    [else
     (make-branch
      (left tree)
      new
      (right tree))]))


(check-expect (bst-insert < 4 LEAF) TREE-4)
(check-expect (bst-insert < 2 TREE-4)
              (make-branch TREE-2 4 LEAF))
(check-expect (bst-insert < 4 TREE-4) TREE-4)
(check-expect (bst-insert < 3 TREE-245678)
              (make-branch
               (make-branch
                LEAF
                2
                (make-branch TREE-3 4 LEAF))
               5
               TREE-678))
(check-expect (bst-insert < 9 TREE-245678)
              (make-branch
               TREE-24
               5
               (make-branch
                TREE-6
                7
                (make-branch
                 LEAF
                 8
                 TREE-9))))


; [Ord X] X [BST X] -> [BST X]
; Removes an element from a BST. Makes no attempt to preserve balance—removes
; an element by replacing it with its in-order successor (i.e., the
; leftmost child of its right child).
; ASSUMPTION: (bst? lt? tree)
(define (bst-remove lt? old tree)
  (local
    [(define (extract-leftmost-child subtree)
       (cond
         [(leaf? (left subtree))
          (list (element subtree) (right subtree))]
         [(branch? (left subtree))
          (local
            [(define least/rest (extract-leftmost-child (left subtree)))]
            (list (first least/rest)
                  (make-branch (second least/rest)
                               (element subtree)
                               (right subtree))))]))]
    (cond
      [(leaf? tree) tree]
      [(lt? old (element tree))
       (make-branch
        (bst-remove lt? old (left tree))
        (element tree)
        (right tree))]  
      [(lt? (element tree) old)
       (make-branch
        (left tree)
        (element tree)
        (bst-remove lt? old (right tree)))]
      [(leaf? (right tree))
       (left tree)]
      [else
       (local
         [(define least/rest (extract-leftmost-child (right tree)))]
         (make-branch
          (left tree)
          (first least/rest)
          (second least/rest)))])))

(check-expect (bst-remove < 3 LEAF) LEAF)
(check-expect (bst-remove < 2 TREE-24) TREE-4)
(check-expect (bst-remove < 3 TREE-24) TREE-24)
(check-expect (bst-remove < 4 TREE-24)
              (make-branch LEAF 2 LEAF))
(check-expect (bst-remove < 6 TREE-678)
              (make-branch LEAF 7 (make-branch LEAF 8 LEAF)))
(check-expect (bst-remove < 7 TREE-678)
              (make-branch (make-branch LEAF 6 LEAF) 8 LEAF))
(check-expect (bst-remove < 8 TREE-678)
              (make-branch (make-branch LEAF 6 LEAF) 7 LEAF))
(check-expect (bst-remove < 1 TREE-245678) TREE-245678)
(check-expect (bst-remove < 2 TREE-245678)
              (make-branch TREE-4 5 TREE-678))
(check-expect (bst-remove < 3 TREE-245678) TREE-245678)
(check-expect (bst-remove < 4 TREE-245678)
              (make-branch (make-branch LEAF 2 LEAF) 5 TREE-678))
(check-expect (bst-remove < 5 TREE-245678)
              (make-branch TREE-24
                           6
                           (make-branch LEAF 7 TREE-8)))
(check-expect (bst-remove < 6 TREE-245678)
              (make-branch TREE-24
                           5
                           (make-branch LEAF 7 TREE-8)))
(check-expect (bst-remove < 7 TREE-245678)
              (make-branch TREE-24
                           5
                           (make-branch TREE-6 8 LEAF)))

;;; Example of imbalance:

; Nat -> [BST Integer]
; Constructs a tree of height Θ(n).
(define (make-list-tree n)
  (foldl (lambda (element tree) (bst-insert < element tree))
         LEAF
         (build-list n (lambda (i) i))))

(define TREE-0123456789 (make-list-tree 10))
(check-expect
 TREE-0123456789
 (make-branch
  LEAF 0
  (make-branch
   LEAF 1
   (make-branch
    LEAF 2
    (make-branch
     LEAF 3
     (make-branch
      LEAF 4
      (make-branch
       LEAF 5
       (make-branch
        LEAF 6
        (make-branch
         LEAF 7
         (make-branch
          LEAF 8
          (make-branch
           LEAF 9 LEAF)))))))))))

;; See avl.rkt for a solution.
;;; Our BST implementation only works if it's always used with the same
;;; order, but nothing in the interface prevents us from mixing that up.
;;; One solution is to turn [BST X] into an object that carries both data
;;; and operations on that data.

; A [BST% X] is (make-bst% [Searcher X] [Inserter X] [Remover X])
; where
;   a [Searcher X] is [X -> [Or X #f]],
;   an [Inserter X] is [X -> [BST% X]], and
;   a [Remover X] is [X -> [BST% X]].
(define-struct bst% [lookup insert remove])

; [Ord X] -> [BST% X]
(define (new-bst% lt?)
  (let object [(tree LEAF)]
    (make-bst%
     (lambda (element)
       (bst-lookup lt? element tree))
     (lambda (element)
       (object (bst-insert lt? element tree)))
     (lambda (element)
       (object (bst-remove lt? element tree))))))

; X [BST% X] -> [Or X #false]
(define (lookup% element tree) ((bst%-lookup tree) element))
; X [BST% X] -> [BST% X]
(define (insert% element tree) ((bst%-insert tree) element))
; X [BST% X] -> [BST% X]
(define (remove% element tree) ((bst%-remove tree) element))

; [BST% String]
(define empty-string-bst% (new-bst% string<?))
(define BST%-d (insert% "dartmouth" empty-string-bst%))
(define BST%-bd (insert% "berkeley" BST%-d))
(define BST%-abd (insert% "arlington" BST%-bd))
(define BST%-abde (insert% "exeter" BST%-abd))
(define BST%-abdef (insert% "fairfield" BST%-abde))
(define BST%-abdefg (insert% "gloucester" BST%-abdef))
(define BST%-abcdefg (insert% "clarinden" BST%-abdefg))

(define (has/lacks? bst% has lacks)
  (and (andmap string? (map (bst%-lookup bst%) has))
       (andmap false? (map (bst%-lookup bst%) lacks))))

(check-expect (lookup% "fairfield" BST%-abd) #false)
(check-expect (lookup% "fairfield" BST%-abde) #false)
(check-expect (lookup% "fairfield" BST%-abdef) "fairfield")
(check-expect (lookup% "fairfield" BST%-abdefg) "fairfield")
(check-expect (lookup% "arlington" BST%-abdefg) "arlington")
(check-expect (has/lacks? BST%-abdefg
                          '("arlington"
                            "berkeley"
                            "dartmouth"
                            "exeter"
                            "fairfield"
                            "gloucester")
                          '("clarendon"
                            "hereford"))
              #true)

(check-expect (has/lacks?
               (remove% "dartmouth" BST%-abdef)
               '("arlington"
                 "berkeley"
                 "exeter"
                 "fairfield")
               '("clarendon"
                 "dartmouth"
                 "gloucester"))
              #true)
(check-expect (has/lacks?
               (remove% "arlington" (remove% "dartmouth" BST%-abdef))
               '("berkeley"
                 "exeter"
                 "fairfield")
               '("arlington"
                 "clarendon"
                 "dartmouth"
                 "gloucester"))
              #true)

;;; Now see avl.rkt