open Core

module Grid = struct
  type t = char list list

  (* DIRECTIONS AND MOVEMENTS *)
  type direction = Up | Down | Left | Right | UpLeft | UpRight | DownLeft | DownRight
  let directions = [Up; Down; Left; Right; UpLeft; UpRight; DownLeft; DownRight]

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

  let in_bounds (x, y) rows cols =
    x >= 0 && x < rows && y >= 0 && y < cols

  let create_empty_grid (rows : int) (cols : int) : t =
    List.init rows ~f:(fun _ -> List.init cols ~f:(fun _ -> '-'))

  let print_grid (grid : t) : unit =
    List.iter grid ~f:(fun row ->
        List.iter row ~f:(fun col -> Printf.printf "%c " col);
        Printf.printf "\n")
end

(* Function to populate the grid with strings in a snaking pattern *)
let populate_snaking_grid (strings : string list) (rows : int) (cols : int) : Grid.t =
  let total_chars = List.sum (module Int) strings ~f:String.length in
  if total_chars <> rows * cols then
    failwith
      (Printf.sprintf
         "Number of characters (%d) does not match grid size (%d)"
         total_chars
         (rows * cols));

  let grid = ref (Grid.create_empty_grid rows cols) in
  let used_positions = ref [] in  (* List to track used positions *)

  (* Checks if a position is free (within bounds and not already used) *)
  let is_free (x, y) =
    Grid.in_bounds (x, y) rows cols &&
    not (List.exists !used_positions ~f:(fun (ux, uy) -> ux = x && uy = y))
  in

  (* Function to place the letters of a word recursively *)
  let rec place_word (x, y) chars =
    match chars with
    | [] -> ()
    | char :: rest ->
      (* Place the character at the current position *)
      if not (is_free (x, y)) then
        failwith "Invalid placement: Overlapping or out-of-bounds";

      let updated_row =
        List.mapi (List.nth_exn !grid y) ~f:(fun col_idx cell ->
            if col_idx = x then char else cell)
      in
      grid := List.mapi !grid ~f:(fun row_idx row ->
          if row_idx = y then updated_row else row);

      used_positions := (x, y) :: !used_positions;  (* Mark this position as used *)

      (* Try placing the next character in a random valid direction *)
      let rec try_directions directions =
        match directions with
        | [] -> failwith "Unable to place remaining characters"
        | dir :: dirs ->
          let (new_x, new_y) = Grid.move (x, y) dir in
          if is_free (new_x, new_y) then
            place_word (new_x, new_y) rest
          else
            try_directions dirs
      in
      try_directions (List.permute Grid.directions)

  in

  (* Function to place all words *)
  let rec place_words words =
    match words with
    | [] -> ()
    | word :: rest ->
      (* Start from the first free cell in the grid *)
      let rec find_valid_start () =
        let start_x = Random.int cols in
        let start_y = Random.int rows in
        if is_free (start_x, start_y) then (start_x, start_y)
        else find_valid_start ()
      in
      let (start_x, start_y) = find_valid_start () in
      place_word (start_x, start_y) (String.to_list word);
      place_words rest
  in

  place_words strings;
  !grid

let () =
  let rows = 8 in
  let cols = 6 in
  let strings = ["blueberry"; "apple"; "mandarin"; "mango"; "orange"; "grape"; "strawberry"] in
  
  (* Populate the grid with the strings *)
  let grid = populate_snaking_grid strings rows cols in
  
  (* Print the populated grid *)
  Grid.print_grid grid