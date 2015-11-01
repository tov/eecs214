;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname complexity) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t quasiquote repeating-decimal #t #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sum-list : [List-of Number] -> Number
; computes the length of a list
(define (sum-list lon)
  (cond
    [(empty? lon) 0]
    [(cons? lon)  (+ (first lon)
                     (sum-list (rest lon)))]))

(check-expect (sum-list '())                                      0)
(check-expect (sum-list (cons 4 '()))                             4)
(check-expect (sum-list (cons 3 (cons 4 '())))                    7)
(check-expect (sum-list (cons 2 (cons 3 (cons 4 '()))))           9)
(check-expect (sum-list (cons 1 (cons 2 (cons 3 (cons 4 '()))))) 10)























;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; element-of? : X [List-of X] -> Boolean
; determines whether a value is an element of a list
(define (element-of? x lox)
  (cond
    [(empty? lox) #false]
    [(cons? lox)  (or (equal? x (first lox))
                      (element-of? x (rest lox)))]))

(check-expect (element-of? 3 '())       #false)
(check-expect (element-of? 3 '(2 4))    #false)
(check-expect (element-of? 3 '(2 3 4))  #true)













;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; count-repetitions : [List-of X] -> N
; counts the number of repeated elements in a list
(define (count-repetitions lox)
  (cond
    [(cons? lox)  (+ (if (element-of? (first lox) (rest lox)) 1 0)
                     (count-repetitions (rest lox)))]
    [(empty? lox) 0]))

(check-expect (count-repetitions '()) 0)
(check-expect (count-repetitions '(1)) 0)
(check-expect (count-repetitions '(1 2)) 0)
(check-expect (count-repetitions '(1 2 1)) 1)
(check-expect (count-repetitions '(1 2 3 2 1)) 2)
(check-expect (count-repetitions '(1 2 3 2 1 2 4)) 3)



















;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; mergesort : [X X -> Boolean] [List-of X] -> [List-of X]
; mergesorts a list using the given less-than predicate
(define (mergesort <? lox)
  (local
    [(define (split-and-merge lox half-a half-b)
       (cond
         [(cons? lox)  (split-and-merge (rest lox)
                                        (cons (first lox) half-b)
                                        half-a)]
         [(empty? lox) (merge (mergesort <? half-a)
                              (mergesort <? half-b))]))
     (define (merge lox1 lox2)
       (cond
         [(empty? lox1) lox2]
         [(empty? lox2) lox1]
         [(<? (first lox1) (first lox2))
          (cons (first lox1) (merge (rest lox1) lox2))]
         [else
          (cons (first lox2) (merge lox1 (rest lox2)))]))]
    (if (or (empty? lox) (empty? (rest lox)))
        lox
        (split-and-merge lox '() '()))))

(check-expect (mergesort < '()) '())
(check-expect (mergesort < '(2)) '(2))
(check-expect (mergesort < '(8 3 1 5 2 4 7 0 6)) '(0 1 2 3 4 5 6 7 8))