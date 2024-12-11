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

  val print_all_coords : t -> unit


end


(* Validate function signature *)
val check_result : string -> (int * int) list -> WordCoords.t -> bool



