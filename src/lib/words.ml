(* Module to create a map where the key is a word and the value is a Position (int, int) *)
module Position = struct
  type t = int * int

  let compare = compare
end

module StringMap = Map.Make(String)

(** Type wordcoords is a map where the key is a string and the value is a list of positions *)
type wordcoords = (Position.t list) StringMap.t

(* Module to create a map where the key is a word (string) and the value is a record (0 or 1) *)
module WordRecord = struct
  (* Create a map with a string key and int value using Map.Make *)
  module M = Map.Make(String)

  type t = int M.t

  (* Create an empty map *)
  let empty = M.empty

  (* Add a key-value pair to the map *)
  let add word record map = M.add word record map

  (* Find the record for a given word in the map *)
  let find word map = M.find word map

  (* Update the record for a given word in the map *)
  let update word record map =
    M.update word (function
        | Some _ -> Some record
        | None -> Some record
      ) map

  (* Iterate over all word-record pairs in the map *)
  let iter f map = M.iter f map
end

(* Functions for interacting with Front-End are below: *)