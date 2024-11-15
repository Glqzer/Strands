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


