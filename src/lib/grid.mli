open Core

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
  val place_spangram : string -> Alpha.t list list -> Alpha.t list list * (int * int) list
  val print_grid : t -> unit
  val find_next_placement_vertical : t -> int -> int -> Coord.t option
  val find_next_placement_horizontal : t -> int -> int -> Coord.t option
  val attempt_place_word : t -> Coord.t -> char list -> int -> int -> [ `Up | `Down | `Left | `Right | `UpLeft | `UpRight | `DownLeft | `DownRight ] list -> int -> t * bool
  val attempt_place_word_no_orphans : t -> Coord.t -> char list -> int -> int -> [ `Up | `Down | `Left | `Right | `UpLeft | `UpRight | `DownLeft | `DownRight ] list -> int -> t * bool
  val place_words_from_list_vertical_search : t -> string list -> int -> int -> t
  val place_words_from_list_horizontal_search : t -> string list -> int -> int -> t
  val place_final_words : t -> string list -> int -> int -> t
  val place_all_words : string list -> t -> t
  val split_at : int -> 'a list -> 'a list * 'a list
  val is_grid_full: t -> int -> int -> bool
  val retry_place_all_words : string list -> t -> int -> t
end