;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname binheap) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t quasiquote repeating-decimal #t #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
#|

HW2: Binary Heaps
EECS 214, Fall 2015

Due: Monday, November 16, at 11:59 PM, on Canvas

*** You may work on your own or with one (1) partner. ***

In this assignment, you will implement a fixed-size binary heap. The
structure of the heap is already defined for you in this file—see the
`heap` struct below. The heap is represented using an ASL vector to
contain the elements. (ASL vectors are like other languages' arrays in
that the size is fixed at create time.) Each heap will also contain a
comparison function for ordering the elements of the heap, so that your
implementation can support heaps of integers, heaps of strings, heaps of
whatits, heaps of sporkles, etc.

YOUR TASK

I've supplied a definition of a function `create` that returns a new, empty
heap given a capacity and ordering function. Implementing the remaining
operations is up to you:

 - insert!     : [Heap X] X -> Void

 - find-min    : [Heap X] -> X

 - remove-min! : [Heap X] -> Void

For details, see the function headers provided below, which include
purpose statements as well. Each operation must have worst-case time
complexity O(log n), where n is the number of elements in the heap. In
order to help you factor your program effectively, I've included at the
bottom of this file a list of helper functions with names, signatures
(types), and purpose statements (brief functional descriptions). You are
free to use as much or as little of my design as you like.

EXTRA CREDIT

 - Make your heap expand as necessary to accomodate any number of assertions.
   To achieve this, instead of failing when the heap is full, `insert!` should
   allocate a new vector that doubles the capacity and copy the existing element
   over from the old vector.

DELIVERABLES

 - This file, containing:
    + the `insert!`, `find-min`, and `remove-min!` functions fully defined, and
    + sufficient tests to convince yourself your code’s correctness.

CHANGELOG

[Tue, 10 Nov 2015 17:13:59]
  Changed “in-order” to “level-order” in the description of the heap property.

|#

; A [Maybe X] is one of:
; -- X
; -- #false
; Interpretation: maybe an X, or maybe not

; An [Ord X] is a function [X X -> Boolean]
; Interpretation: a total order on X

; A [Heap X] is (make-heap N [Ord X] [Vector-of X])
(define-struct heap [size lt? data])
;
; Interpretation: Given a heap h,
; - (heap-size h) is the number of elements in the heap
; - (heap-lt? h) is the ordering used by the heap
; - (heap-data h) is a vector containing the heap's elements, where the
;   first (heap-size h) elements are an implicit complete binary tree (i.e.,
;   they contain the level-order traversal of the represented tree as we saw
;   in class.
;
; Invariant: The implicit tree satisfies the min-heap property; that is,
; if c is the index of some node and p is the index of its parent then
;    ((heap-lt? h) p c)
; must be true.

; create : N [Ord X] -> [Heap X]
; Creates a new heap with capacity `capacity` and order `lt?`.
(define (create capacity lt?)
  (make-heap 0 lt? (make-vector capacity #false)))

; insert! : [Heap X] X -> Void
; Adds an element to a heap.
; Error if the heap has reached capacity and cannot grow further.
(define (insert! heap new-element)
  ...)
;;;; my function is 7 lines (but see helpers below) ;;;;

; find-min : [Heap X] -> X
; Returns the least element in the heap.
; Error if the heap is empty.
(define (find-min heap)
  ...)
;;;; my function is 4 lines ;;;;

; remove-min! : [Heap X] -> Void
; Removes the least element in the heap.
; Error if the heap is empty.
(define (remove-min! heap)
  ...)
;;;; my function is 9 lines (but see helpers below) ;;;;

;;;;
;;;; PRIVATE HELPERS
;;;;

;;;;
;;;; Below are the helpers that I used to implement my solution. You
;;;; needn’t use the same design that I did, but they may help.
;;;;

; A [Maybe X] is one of:
; -- #false
; -- X
; Interpretation: maybe an X, or maybe not

; heap:ensure-size! : [Heap X] N -> Void
; Ensures that the heap has room for `size` elements by throwing an error
; if it doesn't.
;;;; my function is 3 lines ;;;;

; heap:percolate-down! : [Heap X] N -> Void
; Restores the heap invariant by percolating down, starting with the element
; at `index`.
;;;; my function is 8 lines ;;;;

; heap:find-smaller-child : [Heap X] N -> [Maybe N]
; Finds the index of the smaller child of node `index`, or `#false` if
; it has no children.
;;;; my function is 9 lines ;;;;

; heap:bubble-up! : [Heap X] N -> Void
; Restores the heap invariant by bubbling up the element at `index`.
;;;; my function is 6 lines ;;;;

; heap:ref : [Heap X] N -> X
; Gets the heap element at `index`.
;;;; my function is 2 lines ;;;;

; heap:set! : [Heap X] N X -> Void
; Sets the heap element at `index`.
;;;; my function is 2 lines ;;;;

; heap:swap! : [Heap X] N N -> Void
; Swaps the heap elements at indices `i` and `j`.
;;;; my function is 5 lines ;;;;

; heap:lt? : [Heap X] N N -> Boolean
; Returns whether the element at `i` is less than the element at `j`
; using the heap's order.
;;;; my function is 2 lines ;;;;

; N is the set of natural numbers
; N+ is the set of positive integers

; heap:left : N -> N+
; Computes the index of the left child of the given index.
;;;; my function is 2 lines ;;;;

; heap:right : N -> N+
; Computes the index of the left child of the given index.
;;;; my function is 2 lines ;;;;

; heap:parent : N+ -> N
; Computes the index of the parent of the given index.
;;;; my function is 2 lines ;;;;
