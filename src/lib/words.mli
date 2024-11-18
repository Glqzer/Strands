open Core

(** Module representing positions as (row, col) coordinates. *)
module Position : sig
  (** Type representing a position as a pair of integers. *)
  type t = int * int

  (** Comparison function for positions. *)
  val compare : t -> t -> int
end

module StringMap : Map.S with type Key.t = String.t

(** Type wordcoords is a map where the key is a string and the value is a list of positions *)
type wordcoords = Position.t list StringMap.t

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

(* Functions for interacting with Front-End are below: *)




