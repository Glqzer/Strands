module Position : sig
  type t = int * int
  val compare : t -> t -> int
end

(* Module to create a map where the key is a word and the value is a list of coordinates *)
module WordCoords : sig

  type t

  (* Create an empty map *)
  val empty : t

  (* Add a letter-coordinate pair to the map *)
  val add : string -> Position.t list -> t -> t

  (* Find the value for a given letter in the map *)
  val find : string -> t -> Position.t list option

  val bindings : t -> (string * Position.t list) list
end

(* Module to create a map where the key is a word (string) and the value is a record (0 or 1) *)
module WordRecord : sig
  type t

  (* Create an empty map *)
  val empty : t

  (* Add a string-int pair to the map *)
  val add : string -> int -> t -> t

  (* Find the value for a given key in the map *)
  val find : string -> t -> int option

  (* Update the value for a given key in the map *)
  val update : string -> int -> t -> t
end

(* Validate function signature *)
val check_result : string -> (int * int) list -> WordCoords.t -> bool

val set_found : string -> WordRecord.t -> WordRecord.t

val is_found : string -> WordRecord.t -> bool

val initialize_word_record : string list -> WordRecord.t



