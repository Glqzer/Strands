open Core
(* potential structure - tam 

module Graph : sig
  module Node : sig
    type position 
    type letter 
    type t

    val compare : t -> t -> int
  end
end  *)

module Position : sig
  type t = int * int 
end

module Cell : sig
  type t = char * Position.t
  val compare : char * Position.t -> char * Position.t -> int
  (* TODO: t_of_sexp *)
  (* TODO: sexp_of_t *)
end

module CellMap : Map.S with type Key.t = Cell.t

type graph = Cell.t list CellMap.t

(* val init_graph : unit -> graph  *)

(* open Core

(** Module representing positions as (row, col) coordinates. *)
module Position : sig
  (** Type representing a position as a pair of integers. *)
  type t = int * int

  (** Comparison function for positions. *)
  val compare : t -> t -> int
end

(* TODO - check this:  wrapped for each cell, there is its position on the graph and its char *)
(* module Cell : sig
  type t = char * Position.t
  (* type t = { letter : char; coords : Position.t } *)
end *)

(** Module for a map where each key is a position and the value is a list of neighboring positions. *)
module PositionMap : Map.S with type Key.t = Position.t

(** Type representing the graph as a map from positions to a list of neighbors. *)
type graph = Position.t list PositionMap.t

(* TODO - Would this be a better implementation than wrapping each cell's position and its letter in a module ? *)
(* type char_graph = char PositionMap.t *)

(** An empty graph. *)
val empty_graph : graph 

(** Add a node to the graph, associating it with a list of neighbors. *)
val add_node : graph -> Position.t -> Position.t list -> graph

(** Get the list of neighbors for a given position in the graph. *)
val get_neighbors : graph -> Position.t -> Position.t list

(** Update the list of neighbors for a given position in the graph *)
val update_neighbors : graph -> Position.t -> Position.t list -> graph

(** Create a graph given a number of rows and columns *)
val initialize_graph : int -> int -> graph

(** Randomly remove one diagonal from each pair of diagonals *)
val remove_random_diagonals : graph -> int -> int -> graph



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
    without overlapping existing characters on the grid. *) *)