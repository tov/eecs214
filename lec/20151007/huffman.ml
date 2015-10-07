module PPrint = struct
  (* Makes a string of `len` spaces. *)
  let spaces len = String.make (max 0 len) ' '

  (* Makes a horizontal line of length `len`. *)
  let hline len = String.make (max 0 len) '-'

  (* Makes a list of `n` copies of `x`. *)
  let rec replicate n0 x =
    let rec loop n acc = if n <= 0 then acc else loop (n - 1) (x :: acc) in
      loop n0 []

  (* Pads a string to length `len`, left aligned. *)
  let padl len s = s ^ spaces (len - String.length s)

  (* Pads a list of strings to left-align them at the same length. *)
  let alignl ss  =
    let width = List.fold_left max 0 (List.map String.length ss) in
      List.map (padl width) ss

  (* Horizonatally appends two lists of strings, given the desired width of the
   * left column and height. *)
  let appendh width height left right =
    let left'  = List.map (padl width)
                          (left @ replicate (height - List.length left) "") in
    let right' = alignl (right @ replicate (height - List.length right) "") in
      List.map2 (^) left' right'

  class tabber = object (self)
    val mutable acc = ""
    method app str   = acc <- acc ^ str
    method fill n c  = self#app (String.make (max 0 (n - String.length acc)) c)
    method tab n     = self#fill n ' '
    method as_string = acc
  end
end

module TreeView = struct
  open PPrint

  type tree_view = {
    offset:     int;
    width:      int;
    height:     int;
    text:       string list;
  }

  let leaf lines =
    let lines' = alignl ("|" :: lines) in
      {
        offset  = 0;
        width   = String.length (List.hd lines');
        height  = List.length lines';
        text    = lines'
      }

  let branch root left right =
    let col1_width   = max (left.width + 2)
                           (String.length root + 3 + left.offset - right.offset) in
    let right_offset = col1_width + right.offset in
    let offset       = max (left.offset + 2)
                           ((left.offset + right_offset) / 2) in
    let width        = col1_width + right.width in
    let child_height = max left.height right.height in
    let height       = child_height + 2 in
    let children     = appendh col1_width child_height left.text right.text in
    let line1        = let tabber = new tabber in
                         tabber#tab offset;
                         tabber#app "|";
                         tabber#tab width;
                         tabber#as_string in
    let line2        = let tabber = new tabber in
                         tabber#tab left.offset;
                         tabber#app "+";
                         tabber#fill offset '-';
                         tabber#app root;
                         tabber#fill right_offset '-';
                         tabber#app "+";
                         tabber#tab width;
                         tabber#as_string in
    let text         = line1 :: line2 :: children in
      { offset; width; height; text; }

  let print tv = List.iter print_endline tv.text
end

module Huffman = struct
  type 'a tree = { weight: int; node: 'a node }
   and 'a node = Leaf of 'a
               | Branch of 'a tree * 'a tree

  let leaf n x = { weight = n; node = Leaf x }

  let branch t1 t2 = { weight = t1.weight + t2.weight; node = Branch (t1, t2) }

  let rec tree_view { weight; node } =
    let weight = string_of_int weight in
    match node with
    | Leaf x          -> TreeView.leaf [weight; x]
    | Branch (t1, t2) -> TreeView.branch weight (tree_view t1) (tree_view t2)

  let print t = TreeView.print (tree_view t)

  let count_string s =
    let module Map = Map.Make(Char) in
    let counts = ref Map.empty in
    let inc c  =
      let new_count = if Map.mem c !counts
                        then Map.find c !counts + 1
                        else 1 in
        counts := Map.add c new_count !counts
    in
      String.iter inc s;
      Map.bindings !counts

  let make_leaves =
    List.map (fun (c, n) -> leaf n ("'" ^ Char.escaped c ^ "'"))

  let rec sum_weights { weight; node } =
    weight + match node with
             | Leaf _ -> 0
             | Branch (t1, t2) -> sum_weights t1 + sum_weights t2

  let example =
    branch (branch (branch (leaf 4 "e")
                           (branch (leaf 2 "n")
                                   (branch (leaf 1 "o") (leaf 1 "u"))))
                   (branch (leaf 4 "a")
                           (branch (leaf 2 "t") (leaf 2 "m"))))
           (branch (branch (branch (leaf 2 "i")
                                   (branch (leaf 1 "x") (leaf 1 "p")))
                           (branch (leaf 2 "h") (leaf 2 "s")))
                   (branch (branch (branch (leaf 1 "r") (leaf 1 "l"))
                                   (leaf 3 "f"))
                           (leaf 7 "' '")))
end

module Forest = struct
  let rec take_drop n xs =
    match n, xs with
    | 0, _ | _, [] -> [], xs
    | n, x::xs'    ->
        let before, after = take_drop (n - 1) xs' in
          x::before, after

  class ['a] combiner combine print = object (self)
    val mutable trees: 'a list = []

    method add_list new_trees = trees <- trees @ new_trees

    method add tree = self#add_list [tree]

    method rem index =
      let before, result::after = take_drop index trees in
        trees <- before @ after;
        result

    method combine ix1 ix2 =
      self#add (combine (self#rem ix1) (self#rem ix2))

    method print =
      let each i item =
        Printf.printf "\n[%d]\n" i;
        let () = print item in
        i + 1 in
      ignore (List.fold_left each 0 trees)
  end

  class forest = object
    inherit [string Huffman.tree] combiner Huffman.branch Huffman.print
  end
end

module H = Huffman

let leaf = Huffman.leaf
let branch = Huffman.branch
let print_tree = Huffman.print

class forest = Forest.forest
