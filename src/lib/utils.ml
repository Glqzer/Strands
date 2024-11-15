(* utils.ml *)

[@@@ocaml.warning "-27"]


type word_dict = (int * string list) list

let read_words (filename : string) : word_dict =
  []

let select_words (word_dict : word_dict) (total_chars : int) : string list =
  []

let convert_sample_grid (sample_grid: string) : char array array =
  let cleaned_grid = 
    String.trim sample_grid
    |> String.split_on_char '['
    |> List.map (fun s -> String.trim s 
      |> String.split_on_char ';'             
      |> List.filter (fun str -> str <> "")
      |> List.map (fun c -> c.[0])) 
  in
    (* convert the list of rows into an array of character arrays *)
    Array.of_list (List.map (Array.of_list) cleaned_grid)
