;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname adt) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t quasiquote repeating-decimal #t #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
(require 2htdp/abstraction)

; bfs : Graph Node -> [List-of Node]
(define (bfs graph start-node)
  (local
    [(define to-do (fifo:empty))
     (define seen  (set:empty))]
    (begin
      (fifo:enqueue! start-node to-do)    
      (recur loop []
        (if (fifo:empty? to-do)
            (set:->list seen)
            (local [(define current (fifo:dequeue! to-do))]
              (begin
                (unless (set:member? current seen)
                  (for/list [(node (graph:successors current graph))]
                    (fifo:enqueue! node to-do)))
                (set:insert! current seen)
                (loop))))))))                 

(define EXAMPLE-GRAPH
  '((a b c)
    (b d e a)
    (c e g)
    (d g)
    (e g)
    (g)
    (h i a)
    (i a)))

;;;;;; simple implementations of ADTs used above

(define-struct fifo-cons [first rest])
(define-struct fifo-container [front back])

; fifo:empty : -> FifoQ
(define (fifo:empty)
  (make-fifo-container '() '()))

; fifo:empty? : FifoQ -> Boolean
(define (fifo:empty? q)
  (empty? (fifo-container-front q)))

; fifo:enqueue! : Element FifoQ ->
(define (fifo:enqueue! elt q)
  (let [(new-cell (make-fifo-cons elt '()))]
    (begin
      (if (fifo:empty? q)
          (set-fifo-container-front! q new-cell)
          (set-fifo-cons-rest! (fifo-container-back q) new-cell))
      (set-fifo-container-back! q new-cell))))


; fifo:dequeue! : FifoQ -> Element
(define (fifo:dequeue! q)
  (if (fifo:empty? q)
      (error "cannot dequeue from empty FIFO")
      (begin0
        (fifo-cons-first (fifo-container-front q))
        (set-fifo-container-front! q (fifo-cons-rest
                                      (fifo-container-front q)))
        (when (fifo:empty? q)
          (set-fifo-container-back! q '())))))

(check-expect
 (fifo:empty? (fifo:empty))
 #true)

(check-error
 (fifo:dequeue! (fifo:empty)))

(check-expect
 (local [(define q (fifo:empty))]
   (begin
     (fifo:enqueue! 1 q)
     (fifo:empty? q)))
 #false)

(check-expect
 (let [(q (fifo:empty))]
   (begin
     (fifo:enqueue! 1 q)
     (fifo:dequeue! q)))
 1)

(check-expect
 (let [(q (fifo:empty))]
   (begin
     (fifo:enqueue! 1 q)
     (fifo:dequeue! q)
     (fifo:empty? q)))
 #true)

(check-error
 (let [(q (fifo:empty))]
   (begin
     (fifo:enqueue! 1 q)
     (fifo:enqueue! 2 q)
     (fifo:dequeue! q)
     (fifo:dequeue! q)
     (fifo:dequeue! q))))

(check-expect
 (let* [(q   (fifo:empty))
        (_   (fifo:enqueue! 1 q))
        (mt1 (fifo:empty? q))
        (e1  (fifo:dequeue! q))
        (mt2 (fifo:empty? q))
        (_   (fifo:enqueue! 2 q))
        (_   (fifo:enqueue! 3 q))
        (_   (fifo:enqueue! 4 q))
        (e2  (fifo:dequeue! q))
        (_   (fifo:enqueue! 5 q))
        (e3  (fifo:dequeue! q))
        (e4  (fifo:dequeue! q))
        (e5  (fifo:dequeue! q))
        (mt3 (fifo:empty? q))]
   (list mt1 mt2 mt3 e1 e2 e3 e4 e5))
 (list #false #true #true 1 2 3 4 5))


(define-struct set-container [contents])

; modify-set-contents! : Set [[List-of Element] -> [List-of Element]] ->
(define (modify-set-contents! set modifier)
  (set-set-container-contents! set (modifier (set-container-contents set))))

; set:empty : -> Set
(define (set:empty)
  (make-set-container '()))

; set:empty? : Set -> Boolean
(define (set:empty? set)
  (empty? (set-container-contents set)))

; set:member? : Element Set -> Boolean
(define (set:member? elt set)
  (member? elt (set-container-contents set)))

; set:insert! : Element Set ->
(define (set:insert! elt set)
  (unless (set:member? elt set)
    (modify-set-contents! set (lambda (lst) (cons elt lst)))))

; set:->list : Set -> [List-of Element]
(define set:->list set-container-contents)

; A Graph is [List-of [List-of Vertex]]
; Interp. an association list of vertices and their successors

; Graph -> [List-of Vertex]
(define (graph:successors node graph)
  (cond
    [(empty? graph) (error "node not found")]
    [(cons? graph)
     (if (equal? node (first (first graph)))
         (rest (first graph))
         (graph:successors node (rest graph)))]))