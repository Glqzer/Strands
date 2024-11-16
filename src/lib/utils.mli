(* our utility functions for the Strands game *)

type word_dict = (int * string list) list
(** type representing a dictionary of words grouped by length,
    where each entry is a pair of word length and list of words with that length *)

(* val read_words : string -> word_dict *)
(** [read_words filename] reads words a text file called [filename] *)

val select_words : word_dict -> int -> string list
(** [select_words word_dict total_chars] selects words from [word_dict] until the
    total character count of the selected words reaches [total_chars] *)

val grid : string -> char list list  
