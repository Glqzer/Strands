(* Module to create a map where the key is a letter (char) and the value is a coordinate (int, int) *)
module WordCoords = struct
  (* Create a map with a char key and (int * int) value using Map.Make *)
  module M = Map.Make(Char)

  (* The map type is now (int * int) (coordinates) M.t *)
  type t = (int * int) M.t

  (* Create an empty map *)
  let empty = M.empty

  (* Add a letter-coordinate pair to the map *)
  let add letter coord map = M.add letter coord map

  (* Find the coordinate for a given letter in the map *)
  let find letter map = M.find letter map

  (* Iterate over all letter-coordinate pairs in the map *)
  let iter f map = M.iter f map
end

(* Module to create a map where the key is a word (string) and the value is a record (0 or 1) *)
module WordRecord = struct
  (* Create a map with a string key and int value using Map.Make *)
  module M = Map.Make(String)

  type t = int M.t  (* The map type is now int M.t *)

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