open Core
open Words

(* represents a single cell in the grid, which can either be empty or filled with a character *)
module Alpha : sig
  type t =
    | Filled of Char.t (* a cell contains a specific character *)
    | Empty            (* an empty cell *)

  (* creates an Alpha.t from a given character; returns Error if it's an invalid character *)
  val make : Char.t -> (t, string) result

  (* retrieves the character stored in a cell; if empty then it shows placehold '-' *)
  val show : t -> Char.t
end

(* represents a coordinate on the grid with x and y positions *)
module Coord : sig
  type t = { x : int; y : int }

  (* checks if a coordinate is within the bounds of a grid of specified width and height *)
  val in_bounds : t -> int -> int -> bool

  (* moves a coordinate in the specified direction, producing a new coordinate *)
  val move : t -> [ `Up | `Down | `Left | `Right | `UpLeft | `UpRight | `DownLeft | `DownRight ] -> t
  
  (* equality function for coordinates *)
  val equal : t -> t -> bool
end

(* represents the main grid and provides functions for manipulation and queries *)
module Grid : sig
  type t = Alpha.t list list (* A 2D grid represented as a list of lists of Alpha.t *)

  (* creates an empty grid with the given width and height. All cells are initialized to Empty *)
  val create_empty_grid : int -> int -> t

  (* gets a hold of the cell on the grid *)
  val get_cell : t -> Coord.t -> Alpha.t option

  (* checks if the coordinate on the grid is free (Alpha.Empty), returns bool *)
  val is_free : Coord.t -> t -> bool

  (* given it's coord record, updates that cell with a specified value *)
  val update_cell : t -> Coord.t -> Alpha.t -> t

  (* function to get neighbors of a coordinate (used in BFS algorithm) *)
  val get_neighbors : Coord.t -> int -> int -> t -> Coord.t list

  (* checks if the grid contains any orphaned cells (3 or fewer cells that are isolated and not connected to any other cells  *)
  val check_no_orphans : Alpha.t list list -> int -> int -> bool 

  (* removes a letter from the grid (back to Alpha.Empty -- used to backtrack *)
  val remove_letter : Alpha.t list list -> Coord.t -> Alpha.t list list 

  (* recursive call to place each letter of the spangram, after checking it meets ALL conditions, else choose another direction *)
  val place_letters : Alpha.t list list -> Coord.t -> char list -> int -> int -> [ `Down | `DownLeft | `DownRight | `Left | `Right | `Up | `UpLeft | `UpRight ] list -> int -> Coord.t list -> WordCoords.t -> string -> Alpha.t list list * WordCoords.t

  (* quick booleans to check if a word can be placed either orientation, depending on its length  *)
  val fits_vertically : int -> bool 
  val fits_horizontally : int -> bool

  (* places the spangram on the grid, randomly chooses a vertical or horizontal path (depends on validity) *)
  val place_spangram : string -> Alpha.t list list -> Alpha.t list list * WordCoords.t

  (* prints the grid to the console -- mainly for visual checking *)
  val print_grid : t -> unit

  (* attempts to place a word starting at a given coordinate in a specific direction. Returns the updated grid, a flag indicating success, and the positions of the placed word *)
  val attempt_place_word : t -> Coord.t -> char list -> int -> int -> [ `Up | `Down | `Left | `Right | `UpLeft | `UpRight | `DownLeft | `DownRight ] list -> int -> Position.t list -> t * bool * Position.t list
  
  (* checks if the grid is fully occupied (no Empty cells remain) *)
  val is_grid_full: t -> int -> int -> bool

  (* retries placing all words in the grid. Used when an initial placement attempt fails; returns the updated grid and word coordinates *)
  val retry_place_all_words : string list -> t -> WordCoords.t -> t * WordCoords.t

  (* finds the next available coordinate for placement; returns None if no valid coordinates are found *)
  val find_next_placement : Alpha.t list list -> int -> int -> bool -> Coord.t option

  (* places words from a given list into the grid. Handles retries and constraints such as avoiding orphaned cells and returns the updated grid, word coordinates, and a list of unplaced words*)
  val place_words_from_list : Alpha.t list list -> string list -> int -> int -> WordCoords.t -> bool -> bool -> string list -> Alpha.t list list * WordCoords.t * string list
  
  (* attempts to place all words into the grid, ensuring all constraints are satisfied; returns the updated grid, word coordinates, and a list of unplaced words *)
  val place_all_words : string list -> Alpha.t list list -> WordCoords.t -> int -> Alpha.t list list * WordCoords.t * string list
end