module type Grid = sig
  type t [@@deriving sexp]    (* type representing a 2D array of characters, i.e., a char array array *)
  type position = int * int   (* type representing a position on the grid as (row, col) *)

  val init : t -> char array array 

  val print_grid : t -> unit 
  (** [print_grid grid] prints [grid] to the console in a readable format. *)

end