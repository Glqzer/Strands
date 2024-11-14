(* this is our game file for managing the player's word search experience *)

type word = string
(** Type representing a word. *)

type position = int * int
(** Type representing a position in the grid as (row, col) *)

val mark_word_found : word -> unit
(** [mark_word_found word] marks [word] as found by the player. *)

val is_spangram : word -> bool
(** [is_spangram word] checks if the word is a spangram, covering one edge of the grid. *)

val check_word_valid : word -> bool
(** [check_word_valid word] checks if the word is a valid word from the selected list. *)

val check_word_length : word -> bool
(** [check_word_length word] checks if the word has more than 3 characters. *)

val print_found_words : unit -> unit
(** [print_found_words ()] prints the list of words the player has found so far. *)
