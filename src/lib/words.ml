module Position = struct
  type t = int * int
  let compare = compare
end

(* Module to create a map where the key is a word and the value is a list of coordinates *)
module WordCoords = struct
  (* Create a map with a char key and (int * int) value using Map.Make *)
  module M = Map.Make(String)

  (* The map type is now (int * int) (coordinates) M.t *)
  type t = Position.t list M.t

  (* Create an empty map *)
  let empty = M.empty

  (* Add a letter-coordinate pair to the map *)
  let add word coord map = M.add word coord map

  (* Find the coordinate for a given letter in the map *)
  let find word map = M.find_opt word map

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
  let find word map = M.find_opt word map

  (* Update the record for a given word in the map *)
  let update word record map =
    M.update word (function
        | Some _ -> Some record
        | None -> Some record
      ) map

  (* Iterate over all word-record pairs in the map *)
  let iter f map = M.iter f map
end

let check_result (word : string) (coords : Position.t list) (word_coords_map : WordCoords.t) : bool = 
  match WordCoords.find word word_coords_map with
  | None -> false (* The word is not a key in the map *)
  | Some stored_coords -> coords = stored_coords (* Check if coords match *)

let set_found (word : string) (word_record_map : WordRecord.t) : WordRecord.t = 
  match WordRecord.find word word_record_map with
  | None -> word_record_map
  | Some _ -> WordRecord.add word 1 word_record_map

let is_found (word : string) (word_record_map : WordRecord.t) : bool = 
  match WordRecord.find word word_record_map with
  | None -> false
  | Some 0 -> false
  | Some 1 -> true 
  (* SHOULD NEVER GET TO THIS POINT *)
  | Some _ -> false 

let initialize_word_record (words : string list) : WordRecord.t = 
  List.fold_left (fun acc word -> WordRecord.add word 0 acc) WordRecord.empty words



