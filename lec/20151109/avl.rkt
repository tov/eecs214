;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname avl) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t quasiquote repeating-decimal #t #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
;; [X, Y] (where X and Y are numbers)stands for the closed interval
;; from X to Y, inclusive.

; A [PreAVLTree B X] is one of:
; -- (make-leaf)
; -- (make-branch B [PreAVLTree B X] X [PreAVLTree B X])
(define-struct leaf [])
(define-struct branch [balance left element right])

(define balance branch-balance)
(define left branch-left)
(define element branch-element)
(define right branch-right)

(define LEAF (make-leaf))
(define TREE-2 (make-branch 0 LEAF 2 LEAF))
(define TREE-3 (make-branch 0 LEAF 3 LEAF))
(define TREE-4 (make-branch 0 LEAF 4 LEAF))
(define TREE-5 (make-branch 0 LEAF 5 LEAF))
(define TREE-6 (make-branch 0 LEAF 6 LEAF))
(define TREE-7 (make-branch 0 LEAF 7 LEAF))
(define TREE-8 (make-branch 0 LEAF 8 LEAF))
(define TREE-9 (make-branch 0 LEAF 9 LEAF))
(define TREE-24 (make-branch 1 LEAF 2 TREE-4))
(define TREE-42 (make-branch -1 TREE-4 2 LEAF))
(define TREE-678 (make-branch 0 TREE-6 7 TREE-8))
(define TREE-245678 (make-branch 0 TREE-24 5 TREE-678))
(define TREE-425678 (make-branch 0 TREE-42 5 TREE-678))

; height 1
(define ALFA (make-branch 0 LEAF "alfa" LEAF))
(define CHARLIE (make-branch 0 LEAF "charlie" LEAF))
(define ECHO (make-branch 0 LEAF "echo" LEAF))
(define GOLF (make-branch 0 LEAF "golf" LEAF))
(define JULIETTE (make-branch 0 LEAF "juliette" LEAF))
(define LIMA (make-branch 0 LEAF "lima" LEAF))
(define NOVEMBER (make-branch 0 LEAF "november" LEAF))
; height 2
(define BRAVO (make-branch 0 ALFA "bravo" CHARLIE))
(define HOTEL (make-branch -1 GOLF "hotel" LEAF))
(define KILO (make-branch 0 JULIETTE "kilo" LIMA))
(define OSCAR (make-branch -1 NOVEMBER "oscar" LEAF))
; height 3
(define DELTA (make-branch -1 BRAVO "delta" ECHO))
(define MIKE (make-branch 0 KILO "mike" OSCAR))
; height 4
(define INDIA (make-branch 1 HOTEL "india" MIKE))
; height 5
(define FOXTROT (make-branch 1 DELTA "foxtrot" INDIA))

(define BAD-BALANCE-TREE
  (make-branch -1 KILO "mike" OSCAR))

(define BAD-BST-TREE
  (make-branch 0 OSCAR "mike" KILO))

; bst? : [Ord X] [PreAVLTree B X] -> Boolean
; Does a AVLish binary tree satisfy the BST property?
;
; Examples:
(check-expect (bst? < LEAF) #true)
(check-expect (bst? < TREE-2) #true)
(check-expect (bst? < TREE-24) #true)
(check-expect (bst? > TREE-24) #false)
(check-expect (bst? < TREE-42) #false)
(check-expect (bst? > TREE-42) #true)
(check-expect (bst? < TREE-245678) #true)
(check-expect (bst? > TREE-245678) #false)
(check-expect (bst? < TREE-425678) #false)
(check-expect (bst? > TREE-425678) #false)
(check-expect (bst? string<? FOXTROT) #true)
(check-expect (bst? string<? BAD-BALANCE-TREE) #true)
(check-expect (bst? string<? BAD-BST-TREE) #false)
;
; Strategy: function composition
(define (bst? lt? tree)
  (local
    [(define edge-marker (vector))
     (define (lt?* a b)
       (or (eq? edge-marker a)
           (eq? edge-marker b)
           (lt? a b)))]
    (bst-within? lt?* edge-marker tree edge-marker)))

; [Ord X] X [PreAVLTree B X] X -> Boolean
; Are all the elements of tree between left-bound and right-bound?
;
; Strategy: structural decomposition (PreAVLTree) with two accumulators
; representing the least and greatest values present in the context.
(define (bst-within? lt? left-bound tree right-bound)
  (cond
    [(leaf? tree)  #true]
    [(branch? tree)
     (and
      (lt? left-bound (element tree))
      (lt? (element tree) right-bound)
      (bst-within? lt? left-bound (left tree) (element tree))
      (bst-within? lt? (element tree) (right tree) right-bound))]))


; lookup : [Ord X] X [PreAVLTree B X] -> [Or X #false]
; ASSUMPTION: (bst? lt? haystack)
(define (lookup lt? needle haystack)
  (cond
    [(leaf? haystack) #false]
    [(lt? needle (element haystack))
     (lookup lt? needle (left haystack))]
    [(lt? (element haystack) needle)
     (lookup lt? needle (right haystack))]
    [else
     (element haystack)]))


; accurate-balances? : [PreAVLTree Integer X] -> Boolean
; Do all the recorded balances match actual height differences?
;
; Examples:
(check-expect (accurate-balances? TREE-2) #true)
(check-expect (accurate-balances? TREE-24) #true)
(check-expect (accurate-balances? TREE-42) #true)
(check-expect (accurate-balances? TREE-425678) #true)
(check-expect (accurate-balances?
               (make-branch 1 TREE-2 5 TREE-678))
               #true)
(check-expect (accurate-balances?
               (make-branch 2 TREE-2 5 TREE-678))
               #false)
(check-expect (accurate-balances?
               (make-branch -2 TREE-425678 0 TREE-4))
               #true)
(check-expect (accurate-balances?
               (make-branch -1 TREE-425678 0 TREE-4))
               #false)
(check-expect (accurate-balances?
               (make-branch 0
                            (make-branch 0 LEAF 3 LEAF)
                            3
                            (make-branch 1 LEAF 3 LEAF)))
              #false)
;
; Strategy: structural decomposition
(define (accurate-balances? tree)
  (local
    [(define (height tree)
       (cond
         [(leaf? tree) 0]
         [(branch? tree)
          (local
            [(define l-height (height (left tree)))
             (define r-height (height (right tree)))]
            (if (or (false? l-height) (false? r-height)
                    (not (= (balance tree) (- r-height l-height))))
              #false
              (+ 1 (max l-height r-height))))]))]
    (number? (height tree))))

; avl-balances? : [PreAVLTree Integer X] -> Boolean
; Are all the balances in [-1, 1]?
;
; Strategy: structural decomposition
(define (avl-balances? tree)
  (cond
    [(leaf? tree) #t]
    [(branch? tree) (and (<= -1 (balance tree) 1)
                         (avl-balances? (left tree))
                         (avl-balances? (right tree)))]))

; avl? : [Ord X] [PreAVLTree Integer X] -> Boolean
; Does the pre-AVL tree satisfy the AVL property?
;
; An AVL tree is a binary search tree where the difference in
; heights between the children of every node is at most one.
;
; Examples:
(check-expect (avl? < TREE-2) #true)
(check-expect (avl? < TREE-24) #true)
(check-expect (avl? < TREE-42) #false)
(check-expect (avl? > TREE-24) #false)
(check-expect (avl? > TREE-42) #true)
(check-expect (avl? < TREE-245678) #true)
(check-expect (avl? < (make-branch
                        0
                        (make-branch 0 LEAF 3 LEAF)
                        3
                        (make-branch 1 LEAF 3 LEAF)))
              #false)
(check-expect (avl? string<? FOXTROT) #true)
(check-expect (avl? string<? BAD-BALANCE-TREE) #false)
(check-expect (avl? string<? BAD-BST-TREE) #false)
;
; Strategy: function composition
(define (avl? lt? tree)
  (and (bst? lt? tree)
       (accurate-balances? tree)
       (avl-balances? tree)))

; An [AVLTree X] is [PreAVLTree [-1, 1] X]
; Invariant: avl?

; An [AVLInsertResult X] is (make-avl-insert-result [AVLTree X] Boolean)
(define-struct avl-insert-result [node grew?])
; Interpretation: grew? tells us that the tree grew in height

;; X [AVLTree X] [X X -> Boolean] -> [AVLTree X]
;; insert an element into the tree
(define (insert le? new tree)
  (avl-insert-result-node (insert/helper le? new tree)))

;; X [AVLTree X] [X X -> Boolean] -> [AVLInsertResult X]
;; insert and report if the tree grew at all
(define (insert/helper le? new tree)
  (local
    [;; Balance [AVLTree X] X  [AVLTree X] -> [AVLInsertResult X]
     ;; insert in the correct side and rebalance
     (define (ins-branch bal lt elt rt)
       (cond
         [(not (le? elt new))
          (rebuild/right bal lt elt (insert/helper le? new rt))]
         [(not (le? new elt))
          (rebuild/left bal (insert/helper le? new lt) elt rt)]
         [else
          (make-avl-insert-result
           (make-branch bal lt new rt)
           #false)]))]
  (cond
    [(branch? tree)
     (ins-branch (balance tree)
                 (left tree)
                 (element tree)
                 (right tree))]
    [else (make-avl-insert-result
           (make-branch 0 LEAF new LEAF)
           #true)])))

;; X Balance [AVLInsertResult X] [AVLTree X] -> [AVLInsertResult X]
;; combine parts of a current node and an insert result into a new result
(define (rebuild/left old-balance left-result elt rt)
  (cond
    [(not (avl-insert-result-grew? left-result))
     (make-avl-insert-result
      (make-branch old-balance
                   (avl-insert-result-node left-result)
                   elt
                   rt)
      #false)]
    [(not (= old-balance -1))
     (make-avl-insert-result
      (make-branch (- old-balance 1)
                   (avl-insert-result-node left-result)
                   elt
                   rt)
      (= old-balance 0))]
    [else
     (make-avl-insert-result
      (rebalance/left (avl-insert-result-node left-result) elt rt)
      #false)]))


;; A [LeftTree X] is (make-branch -1 [AVLTree X] X [AVLTree X])
;; A [RightTree X] is (make-branch 1 [AVLTree X] X [AVLTree X])

;; A [LeftOrRightTree X] is one of:
;; -- [LeftTree X]
;; -- [RightTree X]

;; [AVLTree X] X [AVLTree X] -> [AVLTree X]
(define (rebalance/left lt elt rt)
  (cond
    [(= -1 (balance lt))
     (make-branch 0
                  (left lt)
                  (element lt)
                  (make-branch 0
                               (right lt)
                               elt
                               rt))]
    [(= 1 (balance lt))
     (make-branch 0
                  (make-branch (min 0 (- (balance (right lt))))
                               (left lt)
                               (element lt)
                               (left (right lt)))
                  (element (right lt))
                  (make-branch (max 0 (- (balance (right lt))))
                               (right (right lt))
                               elt
                               rt))]))

(check-expect (rebalance/left
                (make-branch
                  -1
                  (make-branch
                    0
                    (make-branch 0 LEAF 1 LEAF)
                    2
                    (make-branch 0 LEAF 3 LEAF))
                  4
                  (make-branch 0 LEAF 5 LEAF))
                6
                (make-branch 0 LEAF 7 LEAF))
              (make-branch
                0
                (make-branch
                  0
                  (make-branch 0 LEAF 1 LEAF)
                  2
                  (make-branch 0 LEAF 3 LEAF))
                4
                (make-branch
                  0
                  (make-branch 0 LEAF 5 LEAF)
                  6
                  (make-branch 0 LEAF 7 LEAF))))

(check-expect (rebalance/left (make-branch 
                                1
                                (make-branch 0 LEAF 1 LEAF)
                                2
                                (make-branch
                                  -1
                                  (make-branch 0 LEAF 3 LEAF)
                                  4
                                  LEAF))
                              5
                              (make-branch 0 LEAF 6 LEAF))
              (make-branch
                0
                (make-branch
                  0
                  (make-branch 0 LEAF 1 LEAF)
                  2
                  (make-branch 0 LEAF 3 LEAF))
                4
                (make-branch
                  1
                  LEAF
                  5
                  (make-branch 0 LEAF 6 LEAF))))

(check-expect (rebalance/left (make-branch
                                1
                                (make-branch 0 LEAF 1 LEAF)
                                2
                                (make-branch
                                  1
                                  LEAF
                                  3
                                  (make-branch 0 LEAF 4 LEAF)))
                              5
                              (make-branch 0 LEAF 6 LEAF))
              (make-branch
                0
                (make-branch
                  -1
                  (make-branch 0 LEAF 1 LEAF)
                  2
                  LEAF)
                3
                (make-branch
                  0
                  (make-branch 0 LEAF 4 LEAF)
                  5
                  (make-branch 0 LEAF 6 LEAF))))

;; rebalance/right tests

;(check-expect
#;(rebalance/right
                (make-branch 0 LEAF 1 LEAF)
                2
                (make-branch
                  -1
                  (make-branch
                    -1
                    (make-branch 0 LEAF 3 LEAF)
                    4
                    LEAF)
                  5
                  (make-branch 0 LEAF 6 LEAF))
              (make-branch
                0
                (make-branch
                  0
                  (make-branch 0 LEAF 1 LEAF)
                  2
                  (make-branch 0 LEAF 3 LEAF))
                4
                (make-branch
                  1
                  LEAF
                  5
                  (make-branch 0 LEAF 6 LEAF))))

(check-expect (rebalance/right
                (make-branch 0 LEAF 1 LEAF)
                2
                (make-branch
                  -1
                  (make-branch
                    1
                    LEAF
                    3
                    (make-branch 0 LEAF 4 LEAF))
                  5
                  (make-branch 0 LEAF 6 LEAF)))
              (make-branch
                0
                (make-branch -1
                             (make-branch 0 LEAF 1 LEAF)
                             2
                             LEAF)
                3
                (make-branch 0
                             (make-branch 0 LEAF 4 LEAF)
                             5
                             (make-branch 0 LEAF 6 LEAF))))

;; X Balance [AVLTree X] [AVLInsertResult X]
;; combine parts of a current node and an insert result into a new result
(define (rebuild/right old-balance lt elt right-result)
  (cond
    [(not (avl-insert-result-grew? right-result))
     (make-avl-insert-result
       (make-branch old-balance
                    lt
                    elt
                    (avl-insert-result-node right-result))
       #false)]
    [(not (= old-balance 1))
     (make-avl-insert-result
       (make-branch (+ old-balance 1)
                    lt
                    elt
                    (avl-insert-result-node right-result))
       (= old-balance 0))]
    [else
      (make-avl-insert-result
        (rebalance/right lt elt (avl-insert-result-node right-result))
        #false)]))

;; X [AVLTree X] [AVLTree X] -> [AVLTree X]
(define (rebalance/right lt elt rt)
  (cond
    [(= 1 (balance rt))
     (make-branch 0
                  (make-branch 0
                               lt
                               elt
                               (left rt))
                   (element rt)
                  (right rt))]
    [(= -1 (balance rt))
     (make-branch 0
                  (make-branch (min 0 (- (balance (left rt))))
                               lt
                               elt
                               (left (left rt)))
                  (element (left rt))
                  (make-branch (max 0 (- (balance (left rt))))
                               (right (left rt))
                               (element rt)
                               (right rt)))]))
