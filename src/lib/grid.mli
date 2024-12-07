(** alpha module for managing grid cells *)
module Alpha : sig
  type t =
    | Filled of char
    | Empty

  val make : char -> (t, string) result
  val show : t -> char
end

(** coord module for representing coordinates in the grid *)
module Coord : sig
  type t = { x : int; y : int }

  val in_bounds : t -> int -> int -> bool
  val move : t -> [ `Up | `Down | `Left | `Right | `UpLeft | `UpRight | `DownLeft | `DownRight ] -> t
  val equal : t -> t -> bool
end

(** grid module for managing the grid, placing letters, and checking for orphan regions *)
module Grid : sig
  type t = Alpha.t list list  (** this is a 2d grid of Alpha.t cells *)

  val create_empty_grid : int -> int -> t
  val get_cell : t -> Coord.t -> Alpha.t option
  val is_free : Coord.t -> t -> bool
  val update_cell : t -> Coord.t -> Alpha.t -> t
  val get_neighbors : Coord.t -> int -> int -> Coord.t list
  val check_no_orphans : t -> int -> int -> bool
  val place_letters : t -> Coord.t -> char list -> int -> int -> [ `Up | `Down | `Left | `Right | `UpLeft | `UpRight | `DownLeft | `DownRight ] list -> int -> t
  val fits_vertically : int -> int -> bool
  val fits_horizontally : int -> int -> bool
  val place_spangram : string -> t -> t
  val print_grid : t -> unit
  val place_all_words : string list -> Alpha.t list list -> Alpha.t list list
end