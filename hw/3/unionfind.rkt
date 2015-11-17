;; The first 3 lines of this file were inserted by DrRacket. If you copy this
;; file and paste into DrRacket then you will want to delete these 3 lines.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname unionfind) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #t #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))

#|
HW3: Union-Find
Due: Monday, Nov. 23 at 11:59 PM, via Canvas

** You may work on your own or with one (1) partner. **

For this assignment you will implement the union-find data structure
with path compression and weighted union as we saw in class. Unlike in
HW2, the representation itself is not defined for you, so you’ll have
to define it.

See below for two suggested helpers and some code to help with testing.

YOUR TASK

First you will need to define your representation, the UnionFind data
type. Each UnionFind represents a “universe” with a fixed number of
objects identified by consecutive natural numbers from 0.

Then you will have to implement five functions:

  create    : N -> UnionFind            ; O(n)
  size      : UnionFind -> N            ; O(1)
  union!    : UnionFind N N -> Void     ; amortized O(α(n))
  find      : UnionFind N -> N          ; amortized O(α(n))
  same-set? : UnionFind N N -> Boolean  ; amortized O(α(n))

 - (create n) takes a natural number `n` and returns a UnionFind universe
(defined by you) initialized to have `n` objects in disjoint singleton sets
numbered 0 to `n - 1`. Given a universe `uf`, (size uf) returns the number
of objects (not sets!) in the universe—that is, `size` will always return
the number that was passed to `create` when that universe was initialized.

 - Functions `union!` and `find` implement the standard union-find operations:
(union uf n m) unions the set containing `n` with the set containing `m`, if
they are not already one and the sane. (find uf n) returns the representative
(root) object name for the set containing `n`. The `find` function must perform
path compression, and the `union!` function must set the parent of the root of
the smaller set to be the root of the larger set.

 - For convenience, (same-set? uf n m) returns whether objects `n` and `m` are
in the same set according to UnionFind universe `uf`.

DELIVERABLE

This file (unionfind.rkt), containing 1) a definition of your UnionFind
data type, and 2) complete, working definitions of the five functions
specified above. Thorough testing is strongly recommended but will not
be graded.

|#

; A UnionFind is [YOUR DEFINITION HERE]

; create : N -> UnionFind
; Creates a new union-find structure having `size` initially-disjoint
; sets numbered 0 through `(- size 1)`.
(define (create size)
  ...)
;;;; My function is 5 lines using ASL’s `build-vector` ;;;;

; size : UnionFind -> N
; Returns the number of objects in `uf`.
(define (size uf)
  ...)
;;;; My function is 2 lines ;;;;

(check-expect (size (create 12)) 12)

; same-set? : UnionFind N N -> Boolean
; Returns whether objects `obj1` and `obj2` are in the same set.
(define (same-set? uf obj1 obj2)
  ...)
;;;; My function is 2 lines ;;;;

; find : UnionFind N -> N
; Finds the representative (root) object for `obj`.
(define (find uf obj)
  ...)
;;;; My function is 10 lines (using one helper) ;;;;

; union : UnionFind N N -> Void
; Unions the set containing `obj1` with the set containing `obj2`.
(define (union! uf obj1 obj2)
  ...)
;;;; My function is 12 lines (using two helpers) ;;;;

;;;; The suggested helpers below assume a type UnionFindEntry
;;;; that contains both the parent id and the weight for one
;;;; object.

; uf:reparent! : UnionFindEntry UnionFindEntry -> Void
; Sets the parent of `child` to be `parent` and adjusts `parent`’s
; weight accordingly.
; (define (uf:reparent! child parent)
;   ...)
;;;; My function is 5 lines ;;;;

; uf:get-entry : UnionFind N -> UnionFindEntry
; Gets the entry for object `ix`.
; (define (uf:get-entry uf ix)
;   ...)
;;;; My function is 2 lines ;;;;

;;;; TESTING ;;;;

; The code below gives a clean way to test your union-find code. The
; idea is that you write a “script” consisting of “union” commands and
; “same” queries, and then running the script returns a list of the
; results of the 'same queries.

; A UnionFindCommand is one of:
; - (list 'union N N)
; - (list 'same N N)
; Interp.:
; - (list 'union m n) means to union the sets containing `m` and `n`
; - (list 'same m n) means to check whether `m` and `n` are in the same
;   set, producing a boolean in the script output

; A UnionFindScript is [List-of UnionFindCommand]

; run-script : N UnionFindScript -> [List-of Boolean]
; Runs the given script on a new UnionFind universe of size `n`
; and returns the list of query results.
(define (run-script n script)
  (interpret-script! (create n) script))

; interpret-script! : UnionFind UnionFindScript -> [List-of Boolean]
; Runs the given script on a the given UnionFind universe and returns the
; list of query results.
(define (interpret-script! uf script)
  (local
    [(define (interpret-command command)
       (if (symbol=? (first command) 'union)
           (begin
             (union! uf (second command) (third command))
             (interpret-script! uf (rest script)))
           (local
             [(define b (same-set? uf (second command) (third command)))]
             (cons b (interpret-script! uf (rest script))))))]
    (if (null? script) '()
        (interpret-command (first script)))))

; Now some example tests:

(check-expect
 (run-script 10 '())
 '())

(check-expect
 (run-script 10
   '((same 0 1)
     (same 0 2)
     (same 0 3)))
 '(#false #false #false))

(check-expect
 (run-script 10
   '((same 0 1)
     (union 0 1)
     (same 0 1)
     (union 1 2)
     (union 2 3)
     (same 0 3)
     (same 0 4)))
 '(#false #true #true #false))
