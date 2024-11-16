
[@@@ocaml.warning "-27"]

type word_dict = (int * string list) list

(* let read_words (filename : string) : word_dict =
  let input_channel = filename in
  let rec read_lines acc =
      let line = input_channel in 
      if String.length line > 0 then
        let process_line line =
          match String.split_on_chars line ~on:[':'] with
          | [length_str; words_str] ->
              let length = int_of_string (length_str) in
              let words =
                words_str
                |> (fun s -> String.sub s 1 (String.length s - 2)) (* remove outer brackets *)
                |> String.split_on_char ~sep:','                     (* split to individual words *)
                
              in
              (length, words) :: acc
          | _ -> acc (* skip malformed lines *)
        in
        read_lines (process_line line)
      else
        read_lines acc (* skip empty lines *)

  in
    let result = read_lines [] in
      close_in input_channel;
      result *)

(* let () =
  let words = read_words "words.txt" in
  List.iter (fun (length, word_list) ->
      Printf.printf "%d: [%s]\n" length (String.concat ", " word_list))
    words *)

let select_words (word_dict : word_dict) (total_chars : int) : string list =
  []
  






(* hard coded for testing *)
let sample_grid (grid: string) : char list list = 
  let grid = 
    [['e'; 'b'; 'l'; 'y'; 'r'; 'r'];
    ['p'; 'a'; 'r'; 'u'; 'e'; 'b'];
    ['g'; 'e'; 'g'; 'e'; 'a'; 'w'];
    ['m'; 'n'; 'b'; 'r'; 'm'; 'a'];
    ['a'; 'a'; 'r'; 'e'; 't'; 'n'];
    ['n'; 'g'; 'o'; 'r'; 's'; 'd'];
    ['a'; 'o'; 'e'; 'r'; 'n'; 'a'];
    ['p'; 'p'; 'l'; 'y'; 'i'; 'r']]
  in grid