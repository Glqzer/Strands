module Graph : sig 
  type position
  type neighbors

  val init : unit
  val get_neighbors : position -> position list 
  val remove_diagonals : unit -> unit

  val bfs : unit -> unit 
  
  val select_spangram : string list -> string option
  (** [select_spangram words] selects a spangram word from the list [words] 
    that stretches from one edge of the grid to another. *)

  (* TODO more helper based on algo *)
  val place_spangram : unit -> string -> position -> position -> bool
  (** [place_spangram grid spangram start_pos dir] places the spangram [spangram] on [grid]
      starting at [start_pos] and extending in the direction given by [dir].
      Returns true if the spangram was successfully placed, false otherwise. *)

  (** TODO more helper based on algo 

  subset sum 

  **)
  val populate_grid : unit -> string list -> unit
  (** [populate_grid grid words] populates [grid] with the remaining words in [words]
      without overlapping existing characters on the grid. *)
end