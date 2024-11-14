module type Grid = sig
  type t [@@deriving sexp]    (* type representing a 2D array of characters, i.e., a char array array *)
  type position = int * int   (* type representing a position on the grid as (row, col) *)

  val init : unit -> t 
  (** [init ()] initializes an empty grid of size 6x8, will be filled with ' ' spaces to begin *)

  val get_letter : t -> position -> char
  (** [get_letter grid position] returns the letter at [position] in [grid]
    Raises an exception if [position] is out of bounds. *)

  val set_letter : t -> position -> char -> unit
  (** [set_letter grid position letter] sets [letter] at [position] in [grid]
    Raises an exception if [position] is out of bounds. *)

  val select_spangram : string list -> string option
  (** [select_spangram words] selects a spangram word from the list [words] 
    that stretches from one edge of the grid to another. *)

  val place_spangram : t -> string -> position -> position -> bool
  (** [place_spangram grid spangram start_pos dir] places the spangram [spangram] on [grid]
      starting at [start_pos] and extending in the direction given by [dir].
      Returns true if the spangram was successfully placed, false otherwise. *)

  val populate_grid : t -> string list -> unit
  (** [populate_grid grid words] populates [grid] with the remaining words in [words]
      without overlapping existing characters on the grid. *)

  val print_grid : t -> unit 
  (** [print_grid grid] prints [grid] to the console in a readable format. *)

end