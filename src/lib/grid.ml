open Core

(* each cell has an alpha that is either filled or empty *)
module Alpha = struct
  type t =
    | Filled of Char.t
    | Empty

  (* each char must be alphanumeric, avoids punctations, etc. *)
  let make (c : Char.t) : (t, string) result =
    if Char.is_alphanum c then Ok (Filled c) else Error "not an alphanumeric character!"

  (* quick look up / getter *)
  let show = function
    | Filled c -> c
    | Empty -> '-'
end

(* coords to be a record of x and y *)
module Coord = struct
  type t = { x : int; y : int }

  (* checks if a coord is in bounds, returns a bool *)
  let in_bounds { x; y } rows cols =
    x >= 0 && x < cols && y >= 0 && y < rows

  (* calculates how to move in a certain direction *)
  let move { x; y } direction = (* TODO: why does it only work if we use ` in this function? *)
    match direction with
    | `Up -> { x; y = y - 1 }
    | `Down -> { x; y = y + 1 }
    | `Left -> { x = x - 1; y }
    | `Right -> { x = x + 1; y }
    | `UpLeft -> { x = x - 1; y = y - 1 }
    | `UpRight -> { x = x + 1; y = y - 1 }
    | `DownLeft -> { x = x - 1; y = y + 1 }
    | `DownRight -> { x = x + 1; y = y + 1 }

  (* equality function for coordinates *)
  let equal coord1 coord2 =
    coord1.x = coord2.x && coord1.y = coord2.y
end

(* TODO: continue to refactor to use normal variant instead of the code ABOVE using polymorphic variants aka the ` marks *)
(* module Direction = struct
  type t =
  | Up
  | Down
  | Left
  | Right
  | UpLeft
  | UpRight
  | DownLeft
  | DownRight
  (* sometimes need to choose from all possible dirs *)
  [@@deriving enumerate] (* derives val all : t list that contains all of the constructors in a list *)
  
end *)

module Grid = struct
  type t = Alpha.t list list (* 2D grid with alpha letters *)

  (* spangram cannot be 100% random (case where it won't make it to the other edge *)
  (* we control the path decision making by limiting certain directions *)
  let vertical_directions = [`Down; `DownLeft; `DownRight] (* can imagine a random zig-zag motion from top to bottom *)
  let horizontal_directions = [`Right; `UpRight; `DownRight] 
  let all_directions = [`Up; `Down; `Left; `Right; `UpLeft; `DownLeft; `UpRight; `DownRight] (* sometimes need to choose from all possible dirs *)

  let word_placement_directions = [`Down; `DownRight; `Right; `UpRight; `Down; `Right]

  (* creates empty grid with Empty chars *)
  let create_empty_grid rows cols : t =
    List.init rows ~f:(fun _ -> List.init cols ~f:(fun _ -> Alpha.Empty))

  let get_cell grid { Coord.x; y } =
    List.nth grid y |> Option.bind ~f:(fun row -> List.nth row x)

  let is_free coord grid =
    match get_cell grid coord with
    | Some Alpha.Empty -> true
    | _ -> false

  let update_cell grid { Coord.x; y } value =
    List.mapi grid ~f:(fun row_idx row ->
        if row_idx = y then
          List.mapi row ~f:(fun col_idx cell -> if col_idx = x then value else cell)
        else row)

  (* helper function to get neighbors of a coordinate *)
  let get_neighbors coord rows cols =
    List.filter_map all_directions ~f:(fun dir ->
        let new_coord = Coord.move coord dir in
        if Coord.in_bounds new_coord rows cols then Some new_coord else None)

  (* checks for orphan regions in the grid *)
  let check_no_orphans grid rows cols =
  (* helper -- BFS to explore the connected empty cells and accumulate visited cells *)
  let rec bfs visited queue =
    match queue with
    | [] -> visited
    | coord :: rest -> (* pattern match on all the coords in queue *)
      if List.mem visited coord ~equal:Coord.equal then
        bfs visited rest
      else
        match get_cell grid coord with
        | Some Alpha.Empty ->
            let visited = coord :: visited in
            let neighbors = get_neighbors coord rows cols in
            bfs visited (rest @ neighbors)
        | _ -> bfs visited rest
  in

  (* cheks all empty cells, and if they form an orphan region (3 or fewer cells), return false *)
  let check_cell visited { Coord.x; y } =
    match get_cell grid { Coord.x = x; y = y } with
    | Some Alpha.Empty when not (List.mem visited { Coord.x = x; y } ~equal:Coord.equal) ->
        let visited = bfs visited [{ Coord.x = x; y }] in
        List.length visited <= 3  (* found an orphan region with 3 or fewer connected empty cells *)
    | _ -> false
  in

  (* iterating through all rows and columns *)
  (* List.existsi -: 'a list -> f:(int -> 'a -> bool) -> bool *)
  List.existsi grid ~f:(fun y row ->
    List.existsi row ~f:(fun x cell ->
      match cell with
      | Alpha.Empty -> check_cell [] { Coord.x = x; y }  (* call check_cell with an empty visited list initially *)
      | _ -> false))
  |> not  (* return true if no orphan region is found *)

  
  (* recursive call to place each letter of the spangram, after checking it meets ALL conditions, else choose another direction *)
  let rec place_letters grid coord letters rows cols directions retries =
    if retries <= 0 then grid (* retries are just mainly to time out -- good to do so I think since the randomness can get expensive *)
    else
      match letters with
      | [] -> grid (* no more letters of spangram left to place, returns the latest new grid *)
      | letter :: rest ->
        if Coord.in_bounds coord rows cols && is_free coord grid then (* EACH LETTER NEEDS TO BE IN BOUNDS AND NOT OVERLAPPING ANOTHER VALID LETTER *)
          (match Alpha.make letter with (* safety checks that letter is alpha *)
          | Ok alpha_value ->
            (* place the letter and check for orphan regions *)
            let updated_grid = update_cell grid coord alpha_value in
            if check_no_orphans updated_grid rows cols then
              let valid_directions =
                List.filter directions ~f:(fun dir ->
                    let new_coord = Coord.move coord dir in
                    Coord.in_bounds new_coord rows cols && is_free new_coord grid)
              in
              (* --- ERROR FIXED: prevents letters place "off the grid " ---- chose from all directions if none of just vertical (or just horizontal works)*)
              let next_directions = if List.is_empty valid_directions then all_directions else valid_directions in

              let direction = List.random_element_exn next_directions in
              let new_coord = Coord.move coord direction in
              place_letters updated_grid new_coord rest rows cols next_directions retries
            else

              (* if placing the letter creates orphan regions, try a different direction *)
              let fallback_coord = Coord.move coord (List.random_element_exn all_directions) in
              place_letters grid fallback_coord letters rows cols directions (retries - 1)
          | Error _ -> grid) (* skip invalid letters *)
        else
          (* if the current position is invalid, try a random new direction *)
          let fallback_coord = Coord.move coord (List.random_element_exn all_directions) in
          place_letters grid fallback_coord letters rows cols directions (retries - 1)

  let fits_vertically word_length rows = word_length <= rows
  let fits_horizontally word_length cols = word_length <= cols

  (* places the spangram on the grid, randomly chooses a vertical or horizontal path (depends on validity) *)
  let place_spangram spangram grid =
    let rows = List.length grid in
    let cols = List.length (List.hd_exn grid) in
    let letters = String.to_list spangram in
    let word_length = String.length spangram in
    let orientation = 
      (* choose a path at random if the spangram is long enough *)
      if fits_vertically word_length rows && fits_horizontally word_length cols then
        if Random.bool () then `Vertical else `Horizontal
      else if fits_horizontally word_length cols then `Horizontal
      else `Vertical

    (* depending on which orientation was picked, the starting point should be a randomly col or row xs*)
    in match orientation with 
    | `Vertical ->
      let start_coord = { Coord.x = Random.int cols; y = 0 } in
      place_letters grid start_coord letters rows cols vertical_directions 100
    | `Horizontal ->
      let start_coord = { Coord.x = 0; y = Random.int rows } in
      place_letters grid start_coord letters rows cols horizontal_directions 100

  (* prints the grid to the console -- mainly for visual checking *)
  let print_grid grid =
    List.iter grid ~f:(fun row ->
        List.iter row ~f:(fun cell -> Printf.printf "%c " (Alpha.show cell));
        Printf.printf "\n")

        let find_next_placement grid rows cols =
          let rec search x y =
            if y >= cols then None (* No free slot found *)
            else if x >= rows then search 0 (y + 1) (* Move to the next column *)
            else
              let coord = { Coord.x = x; Coord.y = y } in
              if Coord.in_bounds coord rows cols && is_free coord grid then Some coord
              else search (x + 1) y
          in
          search 0 0
      
        let rec attempt_place_word grid coord letters rows cols directions retries =
          if retries <= 0 then (grid, false) (* retries are just mainly to time out -- good to do so I think since the randomness can get expensive *)
          else
            match letters with
            | [] -> (grid, true) (* no more letters of spangram left to place, returns the latest new grid *)
            | letter :: rest ->
              if Coord.in_bounds coord rows cols && is_free coord grid then (* EACH LETTER NEEDS TO BE IN BOUNDS AND NOT OVERLAPPING ANOTHER VALID LETTER *)
                (match Alpha.make letter with (* safety checks that letter is alpha *)
                 | Ok alpha_value ->
                   (* place the letter and check for orphan regions *)
                   let updated_grid = update_cell grid coord alpha_value in
                   if check_no_orphans updated_grid rows cols then
                     let valid_directions =
                       List.filter directions ~f:(fun dir ->
                           let new_coord = Coord.move coord dir in
                           Coord.in_bounds new_coord rows cols && is_free new_coord grid)
                     in
                     (* --- ERROR FIXED: prevents letters place "off the grid " ---- chose from all directions if none of just vertical (or just horizontal works)*)
                     let next_directions = if List.is_empty valid_directions then all_directions else valid_directions in
      
                     let direction = List.random_element_exn next_directions in
                     let new_coord = Coord.move coord direction in
                     attempt_place_word updated_grid new_coord rest rows cols next_directions retries
                   else
      
                     (* if placing the letter creates orphan regions, try a different direction *)
                     let fallback_coord = Coord.move coord (List.random_element_exn all_directions) in
                     attempt_place_word grid fallback_coord letters rows cols directions (retries - 1)
                 | Error _ -> (grid, false)) (* skip invalid letters *)
              else
                (* if the current position is invalid, try a random new direction *)
                let fallback_coord = Coord.move coord (List.random_element_exn all_directions) in
                attempt_place_word grid fallback_coord letters rows cols directions (retries - 1)
      
        let rec place_words_from_list grid words rows cols =
          match words with
          | [] -> grid (* No more words to place, return the final grid *)
          | word :: rest ->
            match find_next_placement grid rows cols with
            | None -> grid (* No more open positions, return the current grid *)
            | Some coord ->
              (* Try to place the current word *)
              let (letters : char list) = String.to_list word in
              let (updated_grid, success) =
                attempt_place_word grid coord (letters : char list) rows cols word_placement_directions 20
              in
              if success then
                (* Word placed successfully, move to the next word *)
                place_words_from_list updated_grid rest rows cols
              else
                (* Failed to place the word, skip to the next one *)
                place_words_from_list grid rest rows cols
        
        let place_all_words words grid = 
          let rows = List.length grid in
          let cols = List.length (List.hd_exn grid) in
          place_words_from_list grid words rows cols

end

let () =
  let grid = Grid.create_empty_grid 8 6 in
  let grid_with_spangram = Grid.place_spangram "blueberry" grid in
  let grid_with_words = Grid.place_all_words ["apple"; "mango"; "banana"; "lime"; "lemon"; "kiwi"; "peach"; "grape"; "plum"; "cherry"; "orange"] grid in
  Printf.printf "Spangram Placement:\n";
  Grid.print_grid grid_with_spangram;
  Printf.printf "Word Placement:\n";
  Grid.print_grid grid_with_words
