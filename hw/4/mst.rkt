;; The first 3 lines of this file were inserted by DrRacket. If you copy this
;; file and paste into DrRacket then you will want to delete these 3 lines.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname msp) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #t #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))

#|
HW4: Graphs and MSTs
Due: Monday, Dec. 7 at 11:59 PM, via Canvas

** You may work on your own or with one (1) partner. **

For this assignment you will implement an API for weighted, undirected
graphs; then you will use this API, along with your solutions to
previous homework assignments, to implement Kruskal’s algorithm for
computing a minimum spanning forest (detailed below).


BACKGROUND

First, some definitions:

  - A graph is *connected* if there is a path from every vertex to every
  other; otherwise it comprises two or more *connected components*, each
  of which is a maximal connected subgraph. (A connected component is
  maximal in the sense that no additional vertices could be added and
  still have it be connected.)

  - A *spanning tree* of a connected graph G is a subgraph that includes
  all of G’s vertices, but only enough edges for it to be connected and
  no more. Cycles would introduce redundant connectivity, so it’s a
  tree. Note that the number of edges in a spanning tree is always one
  less than the number of vertices in the original graph.

  - A *minimum spanning tree* for a connected graph is a spanning tree
  with minimum total weight. (There may be a tie.) We can interpret a
  MST as follows: If vertices represent sites of some kind, edges
  potential connections between them, and weights the costs of those
  edges, then an MST gives the lowest cost way to connect all the
  sites.

  - A graph that isn’t connected has a miniumum spanning tree for each
  of its connected components. This collection of MSTs is a *minimum
  spanning forest.*

The result of Kruskal’s algorithm is a graph with the same vertices as
the input graph, but whose edges form a minimum spanning tree (or
forest). It starts with all of the vertices from the input graph and no
edges, so the result graph starts out completely disconnected. In other
words, each vertex forms its own (degenerate) connected component. The
algorithm works by maintaining the set of connected components in the
result (using a union-find data structure); it repeatedly adds an edge
that connects two components, thus unifying them into one. In
particular, to achieve minimality, it considers the edges in order from
lightest weight to heaviest. For each edge, if its two vertices are
already connected in the result graph, the edge is ignored; but if the
edge would connect vertices that are in two different connected
components then the edge is added to the resulting graph, thus joining
the two components into one. When all edges have been considered then
the result is a minimum spanning tree (or forest, as appropriate).


YOUR TASK, PART I

First you will need to define your representation, the WUGraph data
type. A WUGraph represents a weighted, unordered graph, where vertices
are identified by consecutive natural numbers from 0, and weights are
arbitrary numbers:

;; Vertex is N
;; Weight is Number

The API also uses a data type for weights that includes infinity:

;; A MaybeWeight is either a Weight or +inf.0

Your graph representation is up to you---you may use either adjacency
lists or an adjacency matrix.

Once you’ve defined your graph representation, you will have to
implement five functions for working with graphs:

  make-graph   : N -> WUGraph
  set-edge!    : WUGraph Vertex Vertex MaybeWeight -> Void
  graph-size   : WUGraph -> N
  get-edge     : WUGraph Vertex Vertex -> MaybeWeight
  get-adjacent : WUGraph Vertex -> [List-of Vertex]

To construct a graph, we start with (make-graph n), which returns a new
graph having `n` vertices and no edges. Then we add edges using
(set-edge! g u v w), which connects vertices `u` and `v` by an edge
having weight `w`. The weight `w` may be an actual numeric weight or it
may be +inf.0, which effectively removes the edge.

(graph-size g) returns the number of vertices in `g`, which is the same
as the number originally passed to `make-graph` to create the graph.
(get-edge g u v) returns the weight of the edge from `u` to `v`, which
will be +inf.0 if there is no such edge. Note that because the graph is
undirected, (get-edge g u v) should always be the same as (get-edge g v
u). (This probably means that `set-edge!` needs to maintain an
invariant.) Finally (get-adjacent g v) returns a list of all the
vertices adjacent to `v` in graph `g`---note that an undirected graph
does not distinguish predecessors from successors.


YOUR TASK, PART II

Once you have a working graph API, you should implement Kruskal’s
algorithm as a function

  kruskal-mst : WUGraph -> WUGraph

Given any weighted, undirected graph `g`, (kruskal-mst g) returns a
graph with the same vertices as `g` and edges forming a minimum spanning
forest, using the algorithm as described above.

In order to maintain and query the set of connected components,
Kruskal’s algorithm uses union-find. You should use your union-find data
structure and operations from HW3. There’s no good way to import it, so
you will have to copy and paste. (If you’re working with a different
partner now than you did for HW3 then you may use either your own
union-find or theirs.)

In order to consider the edges in order by increasing weight, Kruskal’s
algorithm requires sorting the edges by weight. I used my HW2 solution
to write a heap sort (which works by adding all the things to sort to a
heap and then removing them), but you may use any sorting algorithm you
wish.

I’ve listed some helpers you may find useful at the bottom of this file.


DELIVERABLE

This file (mst.rkt), containing 1) a definition of your WUGraph data
type, 2) complete, working definitions of the five graph API functions
specified above, and 3) a working implementation of kruskal-mst.
Thorough testing is strongly recommended but will not be graded.

|#

;;;; PART I: WEIGHTED, UNDIRECTED GRAPHS ;;;;

;; Vertex is N

;; Weight is Number

;; A MaybeWeight is one of:
;; -- Weight
;; -- +inf.0
;; Interpretation: the weight of an edge may be a number or infinite
;; (which means no edge)

;; A WUGraph is ... [UP TO YOU!]


;; make-graph : N -> WUGraph
;; Creates a new weighted, undirected graph with n vertices and no
;; edges.
(define (make-graph n)
  ...)
;;;; my function is 2 lines (using build-vector) ;;;;


;; graph-size : WUGraph -> N
;; Returns the number of vertices in the graph.
(define (graph-size g)
  ...)
;;;; my function is 2 lines ;;;;


;; get-edge : WUGraph Vertex Vertex -> MaybeWeight
;; Gets the weight of the edge from v to u, or infinity if there
;; is no such edge.
;;
;; For any g, v, and u, it ought to be the case that
;;   (= (get-edge g v u) (get-edge g u v))
(define (get-edge g v u)
  ...)
;;;; my function is 2 lines ;;;;


;; set-edge! : WUGraph Vertex Vertex MaybeWeight -> Void
(define (set-edge! g u v weight)
  ...)
;;;; my function is 4 lines ;;;;


;; get-adjacent : WUGraph Vertex -> [List-of Vertex]
(define (get-adjacent g v)
  ...)
;;;; my function is 3 lines (using build-list and filter) ;;;;


;;;; PART II: KRUSKAL’S ALGORITHM ;;;;

;; kruskal-mst : WUGraph -> WUGraph
;; Returns the minimum spanning forest for a given graph, represented as
;; another graph.
(define (kruskal-mst g)
  ...)
;;;; my function is 14 lines, using several helpers (below) ;;;;


;;;;
;;;; TESTING
;;;;

;; The following function may be convenient for creating graphs for
;; tests. It uses the graph API that you are defining above, so if you
;; define make-graph and set-edge! correctly then it will work.

;; build-graph : N [List-of (list Vertex Vertex Weight)] -> WUGraph
;; Returns a new graph of n vertices containing the given edges.
(define (build-graph n edges)
  (local [(define new-graph (make-graph n))]
    (begin
      (map (lambda (edge)
             (set-edge! new-graph (first edge) (second edge) (third edge)))
           edges)
      new-graph)))

(define EXAMPLE-GRAPH-0
  (build-graph 6
               '((0 1 5)
                 (0 2 7)
                 (0 3 2)
                 (1 4 9)
                 (1 5 6)
                 (3 5 0)
                 (3 4 1))))

(check-expect (graph-size EXAMPLE-GRAPH-0) 6)
(check-expect (get-edge EXAMPLE-GRAPH-0 0 1) 5)
(check-expect (get-edge EXAMPLE-GRAPH-0 1 0) 5)
(check-expect (get-edge EXAMPLE-GRAPH-0 0 2) 7)
(check-expect (get-edge EXAMPLE-GRAPH-0 2 0) 7)
(check-expect (get-edge EXAMPLE-GRAPH-0 3 5) 0)
(check-expect (get-edge EXAMPLE-GRAPH-0 5 3) 0)

;; check-expect doesn’t like comparing +inf.0, so we can just do
;; the comparison manually:
(check-expect (= +inf.0 (get-edge EXAMPLE-GRAPH-0 0 4)) #true)
(check-expect (= +inf.0 (get-edge EXAMPLE-GRAPH-0 4 0)) #true)

;; Note that my get-adjacent returns a sorted list, but yours doesn’t
;; need to---and if it doesn’t then you will have to modify these tests.
(check-expect (get-adjacent EXAMPLE-GRAPH-0 0) '(1 2 3))
(check-expect (get-adjacent EXAMPLE-GRAPH-0 1) '(0 4 5))
(check-expect (get-adjacent EXAMPLE-GRAPH-0 5) '(1 3))

;; This graph looks like a "wagon wheel" with six spokes emanating from
;; vertex 6 in the center. The weights of the spokes are mostly less
;; than the weights along the perimeter, except that 3 is closer to 2
;; than it is to 6. Thus, the resulting MST is all spokes except that it
;; connects 3 to 2 rather than to 6.
(define EXAMPLE-GRAPH-1
  (build-graph 7
               '((0 1 3)
                 (1 2 3)
                 (2 3 1)
                 (3 4 3)
                 (4 5 3)
                 (6 0 2)
                 (6 1 2)
                 (6 2 2)
                 (6 3 3)
                 (6 4 2)
                 (6 5 2))))

(define EXAMPLE-MST-1 (kruskal-mst EXAMPLE-GRAPH-1))

(check-expect (get-adjacent EXAMPLE-MST-1 0) '(6))
(check-expect (get-adjacent EXAMPLE-MST-1 1) '(6))
(check-expect (get-adjacent EXAMPLE-MST-1 2) '(3 6))
(check-expect (get-adjacent EXAMPLE-MST-1 3) '(2))
(check-expect (get-adjacent EXAMPLE-MST-1 4) '(6))
(check-expect (get-adjacent EXAMPLE-MST-1 5) '(6))
(check-expect (get-adjacent EXAMPLE-MST-1 6) '(0 1 2 4 5))

;; You probably need more tests than these.


;;;;
;;;; HELPERS YOU MAY FIND USEFUL
;;;;

;; get-all-edges/increasing : WUGraph -> [List-of (list Vertex Vertex)]
;; Gets a list of all the edges in the graph sorted by increasing weight;
;; includes only one (arbitrary) direction for each edge.
(define (get-all-edges/increasing g)
  ...)
;;;; my function is 4 lines ;;;;

;; get-all-edges : WUGraph -> [List-of (list Vertex Vertex)]
;; Gets all the edges in a graph as a list of 2-element lists; includes
;; only one (arbitrary) direction for each edge.
(define (get-all-edges g)
  ...)
;;;; my function is 13 lines ;;;;

;; heap-sort : [Ord X] [List-of X] -> [List-of X]
;; Sorts a list based on the given less-than function.
(define (heap-sort lt? xs)
  ...)
;;;; my function is 10 lines ;;;;
;; [Impl. note: a heap sort works by inserting every element into a heap
;; and then removing every element, which yields the elements in sorted
;; order. You may of course use a different sort if you wish.]

;; pq-extract-min! : [Heap X] -> X
;; Removes and returns the minimum heap element.
(define (pq-extract-min! heap)
  ...)
;;;; my function is 4 lines ;;;;
