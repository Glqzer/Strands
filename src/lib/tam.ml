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

  let random_direction () =
    List.nth_exn directions (Random.int (List.length directions))

  (* CONDITIONS / CONSTRAINTS *)
  let in_bounds (x, y) rows cols =
    x >= 0 && x < rows && y >= 0 && y < cols

  let is_free (x, y) grid =
    match List.nth grid y with
    | Some row_data -> (
        match List.nth row_data x with
        | Some cell -> Char.equal cell '-'
        | None -> false)
    | None -> false

  let create_empty_grid (rows : int) (cols : int) : t =
    List.init rows ~f:(fun _ -> List.init cols ~f:(fun _ -> '-'))

  let place_spangram (spangram : string) (grid : char list list) =
    let rows = List.length grid in
    let cols = List.length (List.hd_exn grid) in
    let letters = String.to_list spangram in
  
    let rec place_letters grid (x, y) letters =
      match letters with
      | [] -> grid  (* if no more letters to place, return the grid *)
      | letter :: rest ->
        if in_bounds (x, y) rows cols && is_free (x, y) grid then
          (* place the current letter *)
          let updated_row = List.mapi ~f:(fun i cell -> if i = x then letter else cell) (List.nth_exn grid y) in
          let updated_grid = List.mapi ~f:(fun i row -> if i = y then updated_row else row) grid in

          (* recursively place the next letter in the chosen direction *)
          let direction = random_direction () in
          let (new_x, new_y) = move (x, y) direction in
          place_letters updated_grid (new_x, new_y) rest
        else
          (* if the position is invalid, try a different direction *)
          let direction = random_direction () in
          let (new_x, new_y) = move (x, y) direction in
          place_letters grid (new_x, new_y) letters 
          
    in
    (* start spangram at the top and make our way down *)
    let start_x = Random.int cols in
    let start_y = 0 in  
    place_letters grid (start_x, start_y) letters
    

  let print_grid (grid : t) : unit =
    List.iter grid ~f:(fun row ->
      List.iter row ~f:(fun col -> Printf.printf "%c " col);
      Printf.printf "\n")
end

let () =
  let grid = Grid.create_empty_grid 8 6 in
  let grid_with_spangram = Grid.place_spangram "blueberry" grid in
  Grid.print_grid grid_with_spangram

