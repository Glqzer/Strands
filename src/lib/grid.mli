open Core
open Words

module Alpha : sig
  type t =
    | Filled of Char.t
    | Empty

  val make : Char.t -> (t, string) result
  val show : t -> Char.t
end

module Coord : sig
  type t = { x : int; y : int }

  val in_bounds : t -> int -> int -> bool
  val move : t -> [ `Up | `Down | `Left | `Right | `UpLeft | `UpRight | `DownLeft | `DownRight ] -> t
  val equal : t -> t -> bool
end

module Grid : sig
  type t = Alpha.t list list

  val create_empty_grid : int -> int -> t
  val get_cell : t -> Coord.t -> Alpha.t option
  val is_free : Coord.t -> t -> bool
  val update_cell : t -> Coord.t -> Alpha.t -> t
  val get_neighbors : Coord.t -> int -> int -> t -> Coord.t list
  val check_no_orphans : t -> int -> int -> bool
  val place_spangram : string -> Alpha.t list list -> Alpha.t list list * WordCoords.t
  val print_grid : t -> unit
  val attempt_place_word : t -> Coord.t -> char list -> int -> int -> [ `Up | `Down | `Left | `Right | `UpLeft | `UpRight | `DownLeft | `DownRight ] list -> int -> Position.t list -> t * bool * Position.t list
  val is_grid_full: t -> int -> int -> bool
  val retry_place_all_words : string list -> t -> WordCoords.t -> t * WordCoords.t
  val find_next_placement : Alpha.t list list -> int -> int -> bool -> Coord.t option
  val place_words_from_list : Alpha.t list list -> string list -> int -> int -> WordCoords.t -> bool -> bool -> string list -> Alpha.t list list * WordCoords.t * string list
  val place_all_words : string list -> Alpha.t list list -> WordCoords.t -> int -> Alpha.t list list * WordCoords.t * string list
end