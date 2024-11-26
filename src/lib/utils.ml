open Stdio 
[@@@ocaml.warning "-27"]

(* Hard coded for testing front end *)
let sample_grid : char list list = 
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

(* parses a file and returns a list of words *)
let parse_file (filename : string) : string list = 
  let content = In_channel.read_all filename in 
  let words_list = String.split_on_char ' ' content in 
    List.map String.trim words_list  

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
  
let split_into_letters (s : string) = 
  List.of_seq (String.to_seq s)