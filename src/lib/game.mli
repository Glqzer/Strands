type grid
type word = string
type position = int * int



val create_grid : int -> int -> grid
(** [create_grid rows cols] creates an empty grid with the specified dimensions. *)

val place_word : grid -> word -> position -> bool
(** [place_word grid word position] attempts to place [word] in [grid] at [position]. Returns true if the word fits according to the rules, false otherwise. *)

val is_spangram : grid -> word -> bool
(** [is_spangram grid word] checks if [word] is a spangram, covering every letter in [grid]. *)

val find_words : grid -> word list
(** [find_words grid] returns a list of all valid words that can be formed within [grid]. *)


