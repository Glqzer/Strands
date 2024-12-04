open Core

module Grid = struct
  type t = char list list

  (* DIRECTIONS AND MOVEMENTS *)
  type direction = Up | Down | Left | Right | UpLeft | UpRight | DownLeft | DownRight
  let directions = [Up; Down; Left; Right; UpLeft; UpRight; DownLeft; DownRight]

  let vertical_directions = [Down; Right; UpRight; DownRight]


  let move (x, y) direction =
    match direction with
    | Up -> (x, y - 1)
    | Down -> (x, y + 1)
    | Left -> (x - 1, y)
    | Right -> (x + 1, y)
    | UpLeft -> (x - 1, y - 1)
    | UpRight -> (x + 1, y - 1)
    | DownLeft -> (x - 1, y + 1)
    | DownRight -> (x + 1, y + 1)

  let is_free (x, y) grid =
    match List.nth grid y with
    | Some row_data -> (
        match List.nth row_data x with
        | Some cell -> Char.equal cell '-'
        | None -> false)
    | None -> false

  let in_bounds (x, y) rows cols =
    x >= 0 && x < rows && y >= 0 && y < cols

  let random_vertical_direction () =
    List.nth_exn directions (Random.int (List.length vertical_directions))

  let create_empty_grid (rows : int) (cols : int) : t =
    List.init rows ~f:(fun _ -> List.init cols ~f:(fun _ -> '-'))

  let print_grid (grid : t) : unit =
    List.iter grid ~f:(fun row ->
        List.iter row ~f:(fun col -> Printf.printf "%c " col);
        Printf.printf "\n")
end

(* FIX ALL OF THIS *)

let rec find_valid_start (x, y) rows cols grid =
  if y >= rows then failwith "No valid starting position found"
  else if Grid.in_bounds (x, y) rows cols && Grid.is_free (x, y) grid then (x, y)
  else
    let next_x = (x + 1) mod cols in
    let next_y = if next_x = 0 then y + 1 else y in
    find_valid_start (next_x, next_y) rows cols grid

let place_vertical_word (start_x, start_y) (word : string) (grid : char list list) =
  let rows = List.length grid in
  let cols = List.length (List.hd_exn grid) in
  let letters = String.to_list word in

  let rec place_letters grid (x, y) letters =
    match letters with
    | [] -> grid  (* if no more letters to place, return the grid *)
    | letter :: rest ->
      if Grid.in_bounds (x, y) rows cols && Grid.is_free (x, y) grid then
        (* place the current letter *)
        let updated_row = List.mapi ~f:(fun i cell -> if i = x then letter else cell) (List.nth_exn grid y) in
        let updated_grid = List.mapi ~f:(fun i row -> if i = y then updated_row else row) grid in

        (* recursively place the next letter in the chosen direction *)
        let direction = Grid.random_vertical_direction () in
        let (new_x, new_y) = Grid.move (x, y) direction in
        place_letters updated_grid (new_x, new_y) rest
      else
        (* if the position is invalid, try a different direction *)
        let direction = Grid.random_vertical_direction () in
        let (new_x, new_y) = Grid.move (x, y) direction in
        place_letters grid (new_x, new_y) letters 

  in
  place_letters grid (start_x, start_y) letters

  let place_words_in_grid (words : string list) (rows : int) (cols : int) : char list list =
    (* Initialize an empty grid *)
    let initial_grid = Grid.create_empty_grid rows cols in
  
    (* Helper function to place each word *)
    let rec place_all_words words grid =
      match words with
      | [] -> grid  (* No more words to place, return the final grid *)
      | word :: rest ->
        (* Find a valid starting position for the current word *)
        let (start_x, start_y) = find_valid_start (0, 0) rows cols grid in
        (* Place the word starting at the valid position *)
        let updated_grid = place_vertical_word (start_x, start_y) word grid in
        (* Recursively place the remaining words *)
        place_all_words rest updated_grid
    in
  
    (* Begin placing words in the grid *)
    place_all_words words initial_grid

let () = 
  let rows = 8 in
  let cols = 6 in
  let words = ["hello"; "world"; "ocaml"; "grid"] in
  let final_grid = place_words_in_grid words rows cols in
  Grid.print_grid final_grid

