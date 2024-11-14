open Core

[@@@ocaml.warning "-27"]


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

module GridImpl : Grid = struct
  type t = char array array [@@deriving sexp]
  type position = int * int

  let init () : t =
    Array.make_matrix ~dimx:6 ~dimy:8 ' '

  let get_letter (grid : t) ((row, col) : position) : char =
    ' '

  let set_letter (grid : t) ((row, col) : position) (letter : char) : unit =
    ()

  let select_spangram (words : string list) : string option =
    None

  let place_spangram (grid : t) (spangram : string) (start_pos : position) (dir : position) : bool =
    false

  let populate_grid (grid : t) (words : string list) : unit =
    ()

  let print_grid (grid : t) : unit =
    ()
end
