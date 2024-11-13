module type Grid = sig
    type t [@@ deriving sexp]
    type position = int * int
  
    val init : int -> int -> t
    (** [init rows cols] creates an empty grid with the specified dimensions. *)
  
    val get_letter : t -> position -> char
    (** [get_letter grid position] gets the letter at [position] in [grid]. *)
  
    val set_letter : t -> position -> char -> unit
    (** [set_letter grid position letter] sets [letter] at [position] in [grid]. *)
  end