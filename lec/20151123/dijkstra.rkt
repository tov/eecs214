;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname dijkstra) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t quasiquote repeating-decimal #t #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))

;;; DIJKSTRA'S ALGORITHM

;; A MaybeVertex is one of:
;; -- Vertex
;; -- -1

;; A MaybeWeight is one of:
;; -- Weight
;; -- +inf.0

;; A DijkstraNodeInfo is (make-dni MaybeVertex MaybeWeight)
;; Interp.: If (make-dni u w) is info about vertex v, that means that:
;; -- u is the predecessor of v on a shortest path (unless u = -1, which
;;    means that v was not found)
;; -- w is the distance (sum of weights) on the shortest path to v that
;;    we've found.

;; A DijkstraResult is [Vector-of DijkstraNodeInfo]
;; Interp.: Each vertex v has info in the vector at index v.

;; dijkstra-sssp : WGraph Vertex -> DijkstraResult
;; Finds the shortest path to each reachable vertex from start.
;; ASSUMPTION: edge weights are non-negative
(define (dijkstra-sssp wg start)
  ...)

;;;; SLOW PRIO-QUEUE API

;; Priority is Number
;; [PQEntry X] is (make-pqentry X Priority)
(define-struct pqentry [value key])

;; A [PrioQueue X] is (make-pq [List-of [PQEntry X]])
;; Invariant: the list is sorted by increasing entry key
(define-struct pq [contents])

;; -> [PrioQueue X]
(define (new-prio-queue)
  (make-pq '()))

;; [PrioQueue X] -> Boolean
(define (prio-queue-empty? pq)
  (empty? (pq-contents pq)))

;; [PrioQueue X] -> X
(define (prio-queue-dequeue pq)
  (local [(define contents (pq-contents pq))]
    (if (empty? contents)
        (error "prio-queue-dequeue: empty")
        (begin
          (set-pq-contents! (rest contents))
          (pqentry-value (first contents))))))

;; [PrioQueue X] Priority X -> Void
(define (prio-queue-insert pq key value)
  (local
    [(define (loop entries)
       (if (and (cons? entries) (< (pqentry-key (first entries)) key))
           (cons (first entries) (loop (rest entries)))
           (cons (make-pqentry value key) entries)))]
    (set-pq-contents! (loop (pq-contents pq)))))
         
           
;;;; WEIGHTED GRAPH API

;; Vertex is N
;; Weight is Number

;; Edge is (make-edge Vertex Weight Vertex)
;; Interp.: (make-edge u w v) represents an edge of weight w from u to v
(define-struct edge [src weight dst])

;; The API uses these accessors directly:

;; edge-src : Edge -> Vertex
;; Returns the source vertex of an edge.

;; edge-dst : Edge -> Vertex
;; Returns the destination vertex of an edge.

;; edge-weight : Edge -> Weight
;; Returns the weight of an edge.

;; WGraph is (make-wgraph Vertex [List-of Edge])
;; Interp. (make-wgraph v e) represents the graph with vertices
;; { 0, 1, ..., (- v 1) }, and edges e.
(define-struct wgraph [size edges])

;; new-graph : N -> WGraph
;; Makes a new graph with `n` vertices.
(define (new-graph n)
  (make-wgraph n '()))

;; get-edge : WGraph Vertex Vertex -> [Or Edge #false]
;; Returns the edge from src to dst, or #false if there is no
;; such edge.
(define (get-edge wg src dst)
  (local [(define es (memf (edge-from-to? src dst) (wgraph-edges wg)))]
    (if (false? es)
      #false
      (first es))))

;; add-edge : WGraph Vertex Weight Vertex -> Void
;; Adds an edge with weight from src to dst, removing any existing edge
;; from src to dst.
;;
;; ASSUMPTION: src, dst < (graph-size wg)
(define (add-edge! wg src weight dst)
  (set-wgraph-edges! wg (cons (make-edge src weight dst)
                              (filter (notp (edge-from-to? src dst))
                                      (wgraph-edges wg)))))

;; get-successor-edges : WGraph Vertex -> [List-of Edge]
;; Returns the list of edges whose source is src.
(define (get-successor-edges wg src)
  (filter (edge-from? src) (wgraph-edges wg)))

;; get-predecessor-edges : WGraph Vertex -> [List-of Edge]
;; Returns the list of edges whose destination is dst.
(define (get-predecessor-edges wg dst)
  (filter (edge-to? dst) (wgraph-edges wg)))

;;;; GRAPH HELPERS

;; edge-from? : Vertex -> [Edge -> Boolean]
;; Returns a predicate for recognizing edges with the given source.
(define (edge-from? src)
  (lambda (edge) (= src (edge-src edge))))

;; edge-to? : Vertex -> [Edge -> Boolean]
;; Returns a predicate for recognizing edges with the given destination.
(define (edge-to? dst)
  (lambda (edge) (= dst (edge-dst edge))))

;; edge-to? : Vertex Vertex -> [Edge -> Boolean]
;; Returns a predicate for recognizing edges with the given source and
;; destination.
(define (edge-from-to? src dst)
  (andp (edge-from? src) (edge-to? dst)))

;; andp : [X -> Boolean] [X -> Boolean] -> [X -> Boolean]
;; Returns a predicate that is the conjunction of two predicates.
(define (andp p1 p2)
  (lambda (x) (and (p1 x) (p2 x))))

;; andp : [X -> Boolean] [X -> Boolean] -> [X -> Boolean]
;; Returns a predicate that is the negation of a predicate.
(define (notp p) (compose not p))

