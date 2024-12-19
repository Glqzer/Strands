open Grid
open Words

(* static example for initial testing,  displays our grid:  Grid.t = Alpha.t list list *)
val static_grid : Grid.t

(* static mapping of the example's words as the key, its values being coordinate pairs *)
val static_coords : WordCoords.t

(* parses the file and returns the list of string words contained in it *)
val parse_file : string -> string list

(* defines the spangram for the grid *)
val get_spangram : string list -> string

(* defines the candidate list of words used for the grid's word population *)
val get_words : string list -> string list

