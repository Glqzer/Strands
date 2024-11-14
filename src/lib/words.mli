(* Module to create a map where the key is a letter (char) and the value is a coordinate (int, int) *)
module WordCoords : sig
  type t

  (* Create an empty map *)
  val empty : t

  (* Add a letter-coordinate pair to the map *)
  val add : char -> int * int -> t -> t

  (* Find the value for a given letter in the map *)
  val find : char -> t -> (int * int)

  (* Iterate over all letter-value pairs in the map *)
  val iter : (char -> int * int -> unit) -> t -> unit
end

(* Module to create a map where the key is a word (string) and the value is a record (0 or 1) *)
module WordRecord : sig
  type t

  (* Create an empty map *)
  val empty : t

  (* Add a string-int pair to the map *)
  val add : string -> int -> t -> t

  (* Find the value for a given key in the map *)
  val find : string -> t -> int

  (* Update the value for a given key in the map *)
  val update : string -> int -> t -> t

  (* Iterate over all key-value pairs in the map *)
  val iter : (string -> int -> unit) -> t -> unit
end



