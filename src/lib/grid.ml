open Core
open Words

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
  type t = { x : int; y : int } [@@deriving compare, sexp]

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

module Grid = struct
  type t = Alpha.t list list (* 2D grid with alpha letters *)

  (* spangram cannot be 100% random (case where it won't make it to the other edge *)
  (* we control the path decision making by limiting certain directions *)
  let vertical_directions = [`Down; `DownLeft; `DownRight] (* can imagine a random zig-zag motion from top to bottom *)
  let horizontal_directions = [`Right; `UpRight; `DownRight] 
  let all_directions = [`Up; `Down; `Left; `Right; `UpLeft; `DownLeft; `UpRight; `DownRight] (* sometimes need to choose from all possible dirs *)

  let word_placement_directions = [`Down; `Right]

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
  let get_neighbors coord rows cols grid =
    (* helper function to check if a direction is blocked by a filled cell *)
    let is_direction_blocked coord dir =
      match Coord.move coord dir with
      | new_coord -> (match get_cell grid new_coord with
          | Some Alpha.Filled _ -> true
          | _ -> false)
    in

    (* list of valid neighbors based on direction and whether diagonal moves are blocked by adjacent filled cells *)
    List.fold_left all_directions ~init:[] ~f:(fun acc dir ->
        let new_coord = Coord.move coord dir in
        if Coord.in_bounds new_coord rows cols then
          (* trying to avoid crossing over diagonals unto another word *)
          match dir with
          | `UpLeft -> if not (is_direction_blocked coord `Up || is_direction_blocked coord `Left) then new_coord :: acc else acc
          | `UpRight -> if not (is_direction_blocked coord `Up || is_direction_blocked coord `Right) then new_coord :: acc else acc
          | `DownLeft -> if not (is_direction_blocked coord `Down || is_direction_blocked coord `Left) then new_coord :: acc else acc
          | `DownRight -> if not (is_direction_blocked coord `Down || is_direction_blocked coord `Right) then new_coord :: acc else acc
          | _ -> new_coord :: acc  (* non-diagonal directions don't need to be blocked *)
        else
          acc  (* if  the neighbor is out of bounds, skip it *)
      )
    |> List.rev  (* reversing to maintain original order of directions *)

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
            let neighbors = get_neighbors coord rows cols grid in  (* pass grid here *)
            bfs visited (rest @ neighbors)
          | _ -> bfs visited rest
    in

    (* checks all empty cells, and if they form an orphan region (3 or fewer cells), return false *)
    let check_cell visited { Coord.x; y } =
      match get_cell grid { Coord.x = x; y = y } with
      | Some Alpha.Empty when not (List.mem visited { Coord.x = x; y } ~equal:Coord.equal) ->
        let visited = bfs visited [{ Coord.x = x; y }] in
        List.length visited <= 3  (* found an orphan region with 3 or fewer connected empty cells *)
      | _ -> false
    in

    (* iterating through all rows and columns *)
    List.existsi grid ~f:(fun y row ->
        List.existsi row ~f:(fun x cell ->
            match cell with
            | Alpha.Empty -> check_cell [] { Coord.x = x; y }  (* call check_cell with an empty visited list initially *)
            | _ -> false))
    |> not  (* return true if no orphan region is found *)

  (* recursive call to place each letter of the spangram, after checking it meets ALL conditions, else choose another direction *)
  let rec place_letters grid coord letters rows cols directions retries spangram_coords map word =
    if retries <= 0 then
      (* restart placement from a new random position if retries are exhausted *)
      let start_coord = { Coord.x = Random.int cols; y = Random.int rows } in
      place_letters grid start_coord letters rows cols directions 100 spangram_coords map word
    else
      match letters with
      | [] -> (grid, map)  (* return the final grid and WordCoords map *)
      | letter :: rest ->  (* place each letter of the spangram *)
        if Coord.in_bounds coord rows cols && is_free coord grid then
          match Alpha.make letter with
          | Ok alpha_value ->
            let updated_grid = update_cell grid coord alpha_value in
            if check_no_orphans updated_grid rows cols then
              let valid_directions =
                List.filter directions ~f:(fun dir ->
                    let new_coord = Coord.move coord dir in
                    Coord.in_bounds new_coord rows cols && is_free new_coord grid)
              in
              let next_directions = if List.is_empty valid_directions then all_directions else valid_directions in
              (match List.random_element next_directions with
               | Some direction ->
                 let new_coord = Coord.move coord direction in

                 (* collects all of the spangram coords*)
                 let updated_spangram_coords = (coord.y, coord.x) :: spangram_coords in

                 (* TODO: clean this up a bit but due to errors i had to convert Coord.t to Position.t and update the WordCoords map from there  *)
                 let updated_map =
                   let existing_coords =
                     match WordCoords.find word map with
                     | Some coords -> coords
                     | None -> []  (* if the word is not found in the map, start with an empty list *)
                   in
                   let position = (coord.y, coord.x) in  (* converting Coord.t to Position.t *)
                   WordCoords.add word (existing_coords @ [position]) map  (* IMPORTANT FOR FRONTEND - add the new position to the list *)
                 in

                 (* recursively place the next letter with the updated map *)
                 place_letters updated_grid new_coord rest rows cols next_directions retries updated_spangram_coords updated_map word
               | None -> (grid, map))  (* if no valid direction, return current grid and map *)
            else
              place_letters grid coord letters rows cols directions (retries - 1) spangram_coords map word
          | Error _ -> (grid, map)  (* error in creating alpha value *)
        else
          place_letters grid coord letters rows cols directions (retries - 1) spangram_coords map word

  let fits_vertically word_length = word_length > 7 
  let fits_horizontally word_length = word_length <= 7 

  (* places the spangram on the grid, randomly chooses a vertical or horizontal path (depends on validity) *)
  let place_spangram spangram grid =
    let rows = List.length grid in
    let cols = List.length (List.hd_exn grid) in
    let letters = String.to_list spangram in
    let word_length = String.length spangram in

    (* creates an empty map to track word coordinates *)
    let map = WordCoords.empty in

    (* chooses at random an orientation, based on spangram length *)
    let orientation =
      if fits_vertically word_length && fits_horizontally word_length then
        if Random.bool () then `Vertical else `Horizontal
      else if fits_horizontally word_length then `Horizontal
      else `Vertical
    in

    (* depending on the orientation v or h, place the letters at random col or row respectively *)
    match orientation with
    | `Vertical ->
      let start_coord = { Coord.x = Random.int cols; y = 0 } in
      place_letters grid start_coord letters rows cols vertical_directions 100 [] map spangram
    | `Horizontal ->
      let start_coord = { Coord.x = 0; y = Random.int rows } in
      place_letters grid start_coord letters rows cols horizontal_directions 100 [] map spangram


  (* prints the grid to the console -- mainly for visual checking *)
  let print_grid grid =
    List.iter grid ~f:(fun row -> 
        List.iter row ~f:(fun cell -> Printf.printf "%c " (Alpha.show cell));
        Printf.printf "\n")

    (* DAVID'S WORDS BELOW *)
    let find_next_placement grid rows cols (is_vertical : bool) =
     if is_vertical then
      let rec search x y =
        if x >= cols then None (* No free slot found *)
        else if y >= rows then search (x + 1) 0 (* Move to the next column *)
        else
          let coord = { Coord.x = x; Coord.y = y } in
          if Coord.in_bounds coord rows cols && is_free coord grid then Some coord
          else search x (y + 1)
      in
      search 0 0
    else 
      let rec search x y =
        if y >= rows then None (* No free slot found *)
        else if x >= cols then search 0 (y + 1) (* Move to the next row *)
        else
          let coord = { Coord.x = x; Coord.y = y } in
          if Coord.in_bounds coord rows cols && is_free coord grid then Some coord
          else search (x + 1) y
      in
      search 0 0

  let rec attempt_place_word grid coord letters rows cols directions retries (placed_positions : Position.t list) =
    if retries <= 0 then (grid, false, List.rev placed_positions) (* Return placed positions in order *)
    else
      match letters with
      | [] -> (grid, true, List.rev placed_positions) (* All letters placed successfully *)
      | letter :: rest ->
        if Coord.in_bounds coord rows cols && is_free coord grid then
          match Alpha.make letter with (* Ensure letter is valid *)
          | Ok alpha_value ->
            (* Place the letter and check for orphan regions *)
            let updated_grid = update_cell grid coord alpha_value in
            if check_no_orphans updated_grid rows cols then
              let valid_directions =
                List.filter directions ~f:(fun dir ->
                    let new_coord = Coord.move coord dir in
                    Coord.in_bounds new_coord rows cols && is_free new_coord grid)
              in
              (* Choose a direction or fallback to all directions if none are valid *)
              let next_directions = if List.is_empty valid_directions then all_directions else valid_directions in
              let direction = List.random_element_exn next_directions in
              let new_coord = Coord.move coord direction in
              attempt_place_word updated_grid new_coord rest rows cols next_directions retries (((coord.y, coord.x) : Position.t) :: placed_positions)
            else
              (* If placing the letter creates orphan regions, try a fallback coordinate from the head of placed_positions *)
              (match placed_positions with
               | [] -> (grid, false, List.rev placed_positions)  (* No placed positions, exit the attempt *)
               | (prev_y, prev_x) :: _ ->
                 let fallback_coord = Coord.move { Coord.x = prev_x; Coord.y = prev_y } (List.random_element_exn all_directions) in
                 attempt_place_word grid fallback_coord letters rows cols directions (retries - 1) placed_positions
              )
          | Error _ -> (grid, false, List.rev placed_positions) (* Skip invalid letters *)
        else
          (grid, false, List.rev placed_positions)
  (* If the current position is invalid, try a random new direction *)
  (* let fallback_coord = Coord.move coord (List.random_element_exn all_directions) in
     attempt_place_word grid fallback_coord letters rows cols directions (retries - 1) placed_positions *)

  let rec attempt_place_word_no_orphans grid coord letters rows cols directions retries (placed_positions : Position.t list) =
    if retries <= 0 then (grid, false, List.rev placed_positions)
    else
      match letters with
      | [] -> (grid, true, List.rev placed_positions)
      | letter :: rest ->
        if Coord.in_bounds coord rows cols && is_free coord grid then
          match Alpha.make letter with
          | Ok alpha_value ->
            let updated_grid = update_cell grid coord alpha_value in
            let valid_directions =
              List.filter directions ~f:(fun dir ->
                  let new_coord = Coord.move coord dir in
                  Coord.in_bounds new_coord rows cols && is_free new_coord grid)
            in
            let next_directions = if List.is_empty valid_directions then all_directions else valid_directions in
            let direction = List.random_element_exn next_directions in
            let new_coord = Coord.move coord direction in
            attempt_place_word_no_orphans updated_grid new_coord rest rows cols next_directions retries (((coord.y, coord.x) : Position.t) :: placed_positions)
          | Error _ -> (grid, false, List.rev placed_positions)
        else          
          (grid, false, List.rev placed_positions)
  (* If the current position is invalid, try a random new direction *)
  (* let fallback_coord = Coord.move coord (List.random_element_exn all_directions) in
     attempt_place_word grid fallback_coord letters rows cols directions (retries - 1) placed_positions *)


  let rec place_words_from_list grid words rows cols (word_coords : WordCoords.t) (is_vertical : bool) =
      match words with
      | [] -> (grid, word_coords) (* No more words to place, return the final grid *)
      | word :: rest ->
        match find_next_placement grid rows cols is_vertical with
        | None -> (grid, word_coords) (* No more open positions, return the current grid *)
        | Some coord ->
          (* Try to place the current word *)
          let (letters : char list) = String.to_list word in
          let (updated_grid, success, position_list) =
            attempt_place_word grid coord (letters : char list) rows cols word_placement_directions 50 []
          in
          if success then
            (* Word placed successfully, move to the next word *)
            let word_coords = WordCoords.add word position_list word_coords in
            place_words_from_list updated_grid rest rows cols word_coords is_vertical
          else
            (* Failed to place the word, skip to the next one *)
            place_words_from_list grid rest rows cols word_coords is_vertical

  let rec place_words_no_orphans grid words rows cols (word_coords : WordCoords.t) flip =
    match words with
    | [] -> (grid, word_coords) (* No more words to place, return the final grid *)
    | word :: rest ->
      match find_next_placement grid rows cols flip with
      | None -> (grid, word_coords) (* No more open positions, return the current grid *)
      | Some coord ->
        (* Try to place the current word *)
        let (letters : char list) = String.to_list word in
        let (updated_grid, success, position_list) =
          attempt_place_word_no_orphans grid coord (letters : char list) rows cols word_placement_directions 50 []
        in
        if success then
          (* Word placed successfully, move to the next word *)
          let word_coords = WordCoords.add word position_list word_coords in
          place_words_no_orphans updated_grid rest rows cols word_coords (flip)
        else
          (* Failed to place the word, skip to the next one *)
          place_words_no_orphans grid rest rows cols word_coords (not flip)

  let split_at n lst =
    let rec aux i acc rest =
      match i, rest with
      | 0, _ -> (List.rev acc, rest)
      | _, [] -> (List.rev acc, [])
      | _, x :: xs -> aux (i - 1) (x :: acc) xs
    in
    aux n [] lst

    let place_all_words words grid (word_coords : WordCoords.t) = 
      let rows = List.length grid in
      let cols = List.length (List.hd_exn grid) in
      let (left, right) = split_at 20 words in
      let (right, final) = split_at 20 right in
      let (grid, word_coords) = place_words_from_list grid left rows cols word_coords true in
      let (grid, word_coords) = place_words_from_list grid right rows cols word_coords false in
      place_words_no_orphans grid final rows cols word_coords true

  let is_grid_full grid rows cols =
    let rec check x y =
      if x >= cols then true (* Checked all columns, grid is full *)
      else if y >= rows then check (x + 1) 0 (* Move to the next column *)
      else
        let coord = { Coord.x = x; Coord.y = y } in
        if Coord.in_bounds coord rows cols && is_free coord grid then false
        else check x (y + 1)
    in
    check 0 0

  let retry_place_all_words words grid max_retries (original_word_coords : WordCoords.t) =
    let rows = List.length grid in
    let cols = List.length (List.hd_exn grid) in

    let rec attempt retries original_grid word_coords =
        let (updated_grid, updated_word_coords) = place_all_words words original_grid word_coords in

          Printf.printf "Trial Placement:\n";
          print_grid updated_grid;

          if is_grid_full updated_grid rows cols then 
            (updated_grid, updated_word_coords)
          else if retries <= 1 then 
            (* If retries are exhausted, return the current grid and word coordinates *)
            (updated_grid, updated_word_coords)
          else
            (* Otherwise, recursively try again with decreased retries *)
            attempt (retries - 1) original_grid original_word_coords
    in

    attempt max_retries grid original_word_coords

end

(* Word placement notes: Must be given a list of at least 15 words of varying lengths of at least 4 *)
let () =
  let grid = Grid.create_empty_grid 8 6 in
  (* BANANA APRICOT MANDARIN BLUEBERRY *)
  let (grid_with_spangram, spangram_coords) = Grid.place_spangram "BANANA" grid in
  let (grid_with_words, word_coords) =
    Grid.retry_place_all_words
      ["1111"; "2222"; "33333"; "44444"; "555555"; "6666"; "77777"; "88888"; "999999";
       "AAAA"; "BBBBB"; "CCCCCC"; "DDDDDD"; "EEEEEEEE"; "FFFF"; "GGGGG"; "HHHHHH";
       "IIIIIII"; "JJJJ"; "KKKKK"; "LLLLLLL"; "MMMM"; "NNNNN"; "OOOOOO"; "PPPPPPP";
       "QQQQ"; "RRRRR"; "SSSSS"; "1111"; "2222"; "33333"; "44444"; "555555"; "6666"; "77777"; "88888"; "999999";
       "AAAA"; "BBBBB"; "CCCCCC"; "DDDDDD"; "EEEEEEEE"; "FFFF"; "GGGGG"; "HHHHHH";
       "IIIIIII"; "JJJJ"; "KKKKK"; "LLLLLLL"; "MMMM"; "NNNNN"; "OOOOOO"; "PPPPPPP";
       "QQQQ"; "RRRRR"; "SSSSS"]
      grid_with_spangram
      25
      spangram_coords
  in

  Printf.printf "Spangram Placement:\n";
  Grid.print_grid grid_with_spangram;

  Printf.printf "Spangram Coordinates (y, x)):\n";
  WordCoords.print_all_coords spangram_coords;

  Printf.printf "Word Placement:\n";
  Grid.print_grid grid_with_words;
  WordCoords.print_all_coords word_coords