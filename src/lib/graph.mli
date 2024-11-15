open Core
(** Module representing positions as (row, col) coordinates. *)
module Position : sig
  (** Type representing a position as a pair of integers. *)
  type t = int * int

  (** Comparison function for positions. *)
  val compare : t -> t -> int
end

(** Module for a map where each key is a position and the value is a list of neighboring positions. *)
module PositionMap : Map.S with type Key.t = Position.t

(** Type representing the graph as a map from positions to a list of neighbors. *)
type graph = Position.t list PositionMap.t

(** An empty graph. *)
val empty_graph : graph

(** Add a node to the graph, associating it with a list of neighbors. *)
val add_node : graph -> Position.t -> Position.t list -> graph

(** Get the list of neighbors for a given position in the graph. *)
val get_neighbors : graph -> Position.t -> Position.t list

(** Update the list of neighbors for a given position in the graph *)
val update_neighbors : graph -> Position.t -> Position.t list -> graph

val initialize_graph : int -> int -> graph

val remove_diagonals : graph -> graph



(* TRY TO GET UNTIL HERE TONIGHT *)

val bfs : graph -> graph

val select_spangram : string list -> string option
(** [select_spangram words] selects a spangram word from the list [words] 
    that stretches from one edge of the grid to another. *)

(* TODO more helper based on algo *)
val place_spangram : unit -> string -> Position.t -> Position.t -> bool
(** [place_spangram grid spangram start_pos dir] places the spangram [spangram] on [grid]
    starting at [start_pos] and extending in the direction given by [dir].
    Returns true if the spangram was successfully placed, false otherwise. *)

(** TODO more helper based on algo 

    subset sum 

 **)
val populate_grid : unit -> string list -> unit
(** [populate_grid grid words] populates [grid] with the remaining words in [words]
    without overlapping existing characters on the grid. *)