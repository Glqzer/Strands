open Core
open Stdio 
open Grid

[@@@ocaml.warning "-27"]


(* hard coded for static example *)
let static_grid = 
  [['f'; 'u'; 'h'; 't'; 's'; 'n'];
  ['l'; 'e'; 'n'; 'i'; 'm'; 'o'];
  ['b'; 'm'; 'c'; 't'; 't'; 'i'];
  ['a'; 'o'; 'd'; 'i'; 'o'; 'p'];
  ['t'; 'u'; 'l'; 'o'; 'd'; 'a'];
  ['u'; 'm'; 'f'; 'e'; 'n'; 'n'];
  ['i'; 'm'; 'u'; 'n'; 'a'; 'o'];
  ['r'; 'o'; 't'; 'c'; 'l'; 'm']]

let update_grid_with_values grid values =
  List.foldi values ~init:grid ~f:(fun row_idx acc_row row ->
    List.foldi row ~init:acc_row ~f:(fun col_idx acc_grid cell ->
      Grid.update_cell acc_grid { Coord.x = col_idx; y = row_idx } (Alpha.Filled cell)
    )
  )

let static_grid =
  let grid =
    Grid.create_empty_grid 8 6
    |> fun grid -> update_grid_with_values grid static_grid
  in grid

  




[@@@coverage off]
(* parses a file and returns a list of words *)
let parse_file (filename : string) : string list =
  let content = In_channel.read_all filename in
  let words_list = String.split ~on:' ' content in
  List.map ~f:String.strip words_list
;;

[@@@coverage on]
(* 
  in our implementation, spangram is the first word of the words list
  and the remaining are the themed words 
*)
let get_spangram (words : string list) =
  match words with 
  | [] -> "" 
  | hd :: tl -> hd           

let get_words (words : string list) = 
  match words with 
  | [] -> []              
  | _ :: tl -> tl   