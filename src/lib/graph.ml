open Core
(* potential structure - tam 

module Graph = struct
  module Node = struct
    type position = int * int
    type letter = char 
    type t = letter * position
    let compare = compare
  end
end
  *)

module Position = struct
  type t = int * int [@@deriving sexp, compare]
end

module Cell = struct
  type t = char * Position.t 
  let compare (char1, pos1) (char2, pos2) =
    match Position.compare pos1 pos2 with
    | 0 -> Char.compare char1 char2 (* if position are the same, compare chars *)
    | other -> other
    let t_of_sexp _ = failwith "not sure"
    let sexp_of_t _ = failwith "not sure"
end

module CellMap = Map.Make(Cell)

(* our graph is a map of Cell keys (char * Postion.t) 
and their values will correspond to their list of neighbors *)
type graph = Cell.t list CellMap.t 

(* let init_graph () : graph =
  let letter = ' ' in
  let rows = 8 in
  let cols = 6 in
  let cells = 
    *)
 





    
(* open Random

module Position = struct
  type t = int * int

  let compare = compare
end

module PositionMap = Map.Make(Position)

type graph = (Position.t list) PositionMap.t

let empty_graph : graph = PositionMap.empty

let add_node graph pos neighbors =
  PositionMap.add pos neighbors graph

let get_neighbors graph pos =
  PositionMap.find pos graph

let update_neighbors graph pos new_neighbors =
  (* Update the graph by adding the new list of neighbors for the given position *)
  PositionMap.add pos new_neighbors graph

let initialize_graph rows cols =
  (* Helper function to get the neighboring positions of a given position. *)
  let neighbors (x, y) =
    (* Create a list of valid neighbors based on grid bounds and diagonals *)
    let neighbor_positions = 
      [(x - 1, y); (x + 1, y); (x, y - 1); (x, y + 1);  (* up, down, left, right *)
       (x - 1, y - 1); (x + 1, y - 1); (x - 1, y + 1); (x + 1, y + 1)]  (* diagonals *)
    in
    (* Filter neighbors to ensure they are within bounds of the grid *)
    List.filter (fun (nx, ny) -> nx >= 0 && nx < rows && ny >= 0 && ny < cols) neighbor_positions
  in

  (* Create the graph by iterating over all possible positions in the grid *)
  let rec create_graph x y graph =
    if x >= rows then graph  (* Base case: finished all rows *)
    else if y >= cols then create_graph (x + 1) 0 graph  (* Go to next column *)
    else
      let pos = (x, y) in
      let neighbor_positions = neighbors pos in
      create_graph x (y + 1) (add_node graph pos neighbor_positions)  (* Add node and continue *)
  in

  create_graph 0 0 empty_graph  (* Start the recursive graph creation from (0, 0) *)
;;

let remove_random_diagonals graph rows cols =
  (* Helper to remove a neighbor from a position's neighbor list *)
  let remove_neighbor neighbors neighbor =
    List.filter ((<>) neighbor) neighbors
  in

  (* Helper function to remove a bidirectional edge between two nodes *)
  let remove_diagonal graph pos1 pos2 =
    let neighbors1 = PositionMap.find_opt pos1 graph |> Option.value ~default:[] in
    let neighbors2 = PositionMap.find_opt pos2 graph |> Option.value ~default:[] in
    let updated_neighbors1 = remove_neighbor neighbors1 pos2 in
    let updated_neighbors2 = remove_neighbor neighbors2 pos1 in
    graph
    |> PositionMap.add pos1 updated_neighbors1
    |> PositionMap.add pos2 updated_neighbors2
  in

  (* Traverse each "box" in the grid *)
  let rec traverse_boxes x y graph =
    if y >= rows - 1 then graph  (* Finished all rows *)
    else if x >= cols - 1 then traverse_boxes 0 (y + 1) graph  (* Move to next row *)
    else
      (* Define positions in the 2x2 box *)
      let pos1 = (x, y) in
      let pos2 = (x + 1, y) in
      let pos3 = (x, y + 1) in
      let pos4 = (x + 1, y + 1) in

      (* Randomly remove one of each pair of crossing diagonals *)
      let graph =
        if Random.bool () then remove_diagonal graph pos1 pos4 else remove_diagonal graph pos2 pos3
      in

      (* Continue to the next box *)
      traverse_boxes (x + 1) y graph
  in

  (* Start the traversal from the top-left corner of the grid *)
  traverse_boxes 0 0 graph
;; *)
