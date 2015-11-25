;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname dijkstra) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t quasiquote repeating-decimal #t #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
;;;; SSSP Types

;; A MaybeVertex is one of:
;; -- Vertex
;; -- -1

;; A MaybeWeight is one of:
;; -- Weight
;; -- +inf.0

;; A VertexInfo is (make-vi MaybeVertex MaybeWeight)
;; Interp.: If (make-vi u w) is info about vertex v, that means that:
;; - u is the predecessor of v on a shortest path (unless u = -1, which
;;   means that v was not found)
;; - w is the distance (sum of weights) on the shortest path to v that
;;   we've found.
(define-struct vi [dist pred])

;; An SsspResult is [Vector-of VertexInfo]
;; Interp.: Each vertex v has info in the vector at index v.

;; initial-sssp-info : N -> SsspResult
;; Initializes the distances to infinity and predecessors to undefined.
(define (initial-sssp-info size)
  (build-vector size (lambda (i) (make-vi +inf.0 -1))))

;; sssp : WDiGraph Vertex -> SsspResult
;; Finds the shortest path to each reachable vertex from start.
#;(define (sssp wg start)
    ...)

;;;; BELLMAN-FORD ALGORITHM

;; bellman-ford-sssp : WDiGraph Vertex -> SsspResult
;; Finds the shortest path to each reachable vertex from start.
(define (bellman-ford-sssp wg start)
  (local
    [(define size (wdg-size wg))
     (define vertex-info (initial-sssp-info size))
     ; Edge -> Void
     (define (relax e)
       (local
         [(define v (edge-src e))
          (define u (edge-dst e))
          (define w (edge-weight e))
          (define dv (vi-dist (vector-ref vertex-info v)))
          (define du (vi-dist (vector-ref vertex-info u)))]
         (when (< (+ dv w) du)
           (begin
             (set-vi-dist! (vector-ref vertex-info u) (+ dv w))
             (set-vi-pred! (vector-ref vertex-info u) v)))))
     ; N -> SsspResult
     (define (for-each-vertex i)
       (when (< i (- size 1))
         (begin
           (map relax (wdg-edges wg))
           (for-each-vertex (+ i 1)))))]
    (begin
      (set-vi-dist! (vector-ref vertex-info start) 0)
      (for-each-vertex 0)
      vertex-info)))


;;;; DIJKSTRA'S ALGORITHM

;; dijkstra-sssp : WDiGraph Vertex -> SsspResult
;; Finds the shortest path to each reachable vertex from start.
;; ASSUMPTION: No edges have negative weight.
(define (dijkstra-sssp wg start)
  (local
    [(define size         (wdg-size wg))
     (define vertex-info  (initial-sssp-info size))
     (define prio-queue   (new-prio-queue))
     ; Vertex Weight -> Void
     (define (set-dist! v dist)
       (begin
         (set-vi-dist! (vector-ref vertex-info v) dist)
         (prio-queue-insert! prio-queue dist v)))
     ; Edge -> Void
     (define (relax e)
       (local
         [(define v (edge-src e))
          (define u (edge-dst e))
          (define w (edge-weight e))
          (define dv (vi-dist (vector-ref vertex-info v)))
          (define du (vi-dist (vector-ref vertex-info u)))]
         (when (< (+ dv w) du)
           (begin
             (set-dist! u (+ dv w))
             (set-vi-pred! (vector-ref vertex-info u) v)))))
     ; Void -> Void
     (define (loop)
       (unless (prio-queue-empty? prio-queue)
         (begin
           (map relax
                (wdg-get-successor-edges wg (prio-queue-dequeue! prio-queue)))
           (loop))))]
  (begin
    (set-dist! start 0)
    (loop)
    vertex-info)))

;;;; TESTS

(define (EXAMPLE-GRAPH-1)
  (local [(define g (wdg-new 7))]
    (begin
      (wdg-add-edge! g 0 5 1)
      (wdg-add-edge! g 1 5 2)
      (wdg-add-edge! g 2 5 6)
      (wdg-add-edge! g 0 1 3)
      (wdg-add-edge! g 3 1 4)
      (wdg-add-edge! g 4 1 5)
      (wdg-add-edge! g 5 1 6)
      (wdg-add-edge! g 4 3 2)
      (wdg-add-edge! g 2 3 4)
      g)))

(define (EXAMPLE-GRAPH-2)
  (make-wdg (wdg-size (EXAMPLE-GRAPH-1))
            (reverse (wdg-edges (EXAMPLE-GRAPH-1)))))
  
(define (BELLMAN-FORD-1) (bellman-ford-sssp (EXAMPLE-GRAPH-1) 0))
(define (DIJKSTRA-1) (dijkstra-sssp (EXAMPLE-GRAPH-1) 0))
(define (BELLMAN-FORD-2) (bellman-ford-sssp (EXAMPLE-GRAPH-2) 0))
(define (DIJKSTRA-2) (dijkstra-sssp (EXAMPLE-GRAPH-2) 0))

(check-expect (BELLMAN-FORD-1)
              (vector (make-vi 0 -1)
                      (make-vi 5 0)
                      (make-vi 5 4)
                      (make-vi 1 0)
                      (make-vi 2 3)
                      (make-vi 3 4)
                      (make-vi 4 5)))
(check-expect (DIJKSTRA-1) (BELLMAN-FORD-1))
(check-expect (BELLMAN-FORD-2) (BELLMAN-FORD-1))
(check-expect (DIJKSTRA-2) (BELLMAN-FORD-1))


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
(define (prio-queue-dequeue! pq)
  (local [(define contents (pq-contents pq))]
    (if (empty? contents)
        (error "prio-queue-dequeue!: empty")
        (begin
          (set-pq-contents! pq (rest contents))
          (pqentry-value (first contents))))))

;; [PrioQueue X] Priority X -> Void
(define (prio-queue-insert! pq key value)
  (local
    [(define (loop entries)
       (if (and (cons? entries) (< (pqentry-key (first entries)) key))
           (cons (first entries) (loop (rest entries)))
           (cons (make-pqentry value key) entries)))]
    (set-pq-contents! pq (loop (pq-contents pq)))))
         
           
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

;; WDiGraph is (make-wgraph Vertex [List-of Edge])
;; Interp. (make-wgraph v e) represents the graph with vertices
;; { 0, 1, ..., (- v 1) }, and edges e.
(define-struct wdg [size edges])

;; wdg-size : WDiGraph -> N
;; Returns the number of vertices.

;; wdg-edges : WDiGraph -> [List-of Edge]
;; Returns a list of all edges in the graph.

;; wdg-new : N -> WDiGraph
;; Makes a new graph with `n` vertices.
(define (wdg-new n)
  (make-wdg n '()))

;; wdg-get-edge : WDiGraph Vertex Vertex -> [Or Edge #false]
;; Returns the edge from src to dst, or #false if there is no
;; such edge.
(define (wdg-get-edge wg src dst)
  (local [(define es (memf (edge-from-to? src dst) (wdg-edges wg)))]
    (if (false? es)
      #false
      (first es))))

;; wdg-add-edge! : WDiGraph Vertex Weight Vertex -> Void
;; Adds an edge with weight from src to dst, removing any existing edge
;; from src to dst.
;;
;; ASSUMPTION: src, dst < (graph-size wg)
(define (wdg-add-edge! wg src weight dst)
  (set-wdg-edges! wg (cons (make-edge src weight dst)
                              (filter (notp (edge-from-to? src dst))
                                      (wdg-edges wg)))))

;; wdg-get-successor-edges : WDiGraph Vertex -> [List-of Edge]
;; Returns the list of edges whose source is src.
(define (wdg-get-successor-edges wg src)
  (filter (edge-from? src) (wdg-edges wg)))

;; wdg-get-predecessor-edges : WDiGraph Vertex -> [List-of Edge]
;; Returns the list of edges whose destination is dst.
(define (wdg-get-predecessor-edges wg dst)
  (filter (edge-to? dst) (wdg-edges wg)))

;;;; INTERNAL GRAPH HELPERS

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

