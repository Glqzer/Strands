module type Grid = sig
  type t [@@deriving sexp]
  type position = int * int

  val init : unit -> t
  val get_letter : t -> position -> char
  val set_letter : t -> position -> char -> unit
  val select_spangram : string list -> string option
  val place_spangram : t -> string -> position -> position -> bool
  val populate_grid : t -> string list -> unit
  val print_grid : t -> unit
end
