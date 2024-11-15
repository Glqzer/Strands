(* utils.ml *)
open Stdlib

[@@@ocaml.warning "-27"]


type word_dict = (int * string list) list

let read_words (filename : string) : word_dict =
  let input_channel = open_in filename in
  (* parse the file, into a word dictionary *)
  let rec read_lines acc =
    match input_line input_channel with
    | line -> 

        let process_line line =
          (* removes unwanted chars and split into key and list of words *)
          let line = String.trim line in
          if String.length line > 0 then
            match String.split_on_char ':' line with
            | [length_str; words_str] ->
                let length = int_of_string (String.trim length_str) in
                let words = String.split_on_char ',' (String.trim words_str) in
                (* clean up the words and associate them with their length *)
                let words = List.map (fun word -> String.trim (String.sub word 1 (String.length word - 2))) words in
                (length, words) :: acc
            | _ -> acc
          else acc
        in
        read_lines (process_line line @ acc)      (* accumulate processed lines *)
   
  in
  let result = read_lines [] in
  close_in input_channel;
  result



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
