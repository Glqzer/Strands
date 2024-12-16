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

  let word_placement_directions = [`Down; `Right; `DownLeft; `DownRight]

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

  let remove_letter grid coord =
    update_cell grid coord Alpha.Empty 
    
  (* recursive call to place each letter of the spangram, after checking it meets ALL conditions, else choose another direction *)
  let rec place_letters grid coord letters rows cols directions retries spangram_coords map word =
    match letters with
    | [] -> (grid, map)  (* return the final grid and map *)
    | letter :: rest ->
      (* retries are exhausted, fallback to the previous state (instead of random new coord in my earlier code) *)
      if retries <= 0 then
        match spangram_coords with
        | [] -> (grid, map) 
        | prev_coord :: prev_rest ->
          (* backtrack, removes the last placed letter and retry *)
          let updated_grid = remove_letter grid prev_coord in
          let updated_spangram_coords = prev_rest in
          let new_retries = 100 in  (* need to reset # of retries *)
            place_letters updated_grid prev_coord (letter :: rest) rows cols directions new_retries updated_spangram_coords map word
      else
        (* attempts to place the current letter, checks if each letter is in bounds and is being placed at a free spot *)
        if Coord.in_bounds coord rows cols && is_free coord grid then

          (* grid should be updated with a valid alpha letter *)
          match Alpha.make letter with
          | Ok alpha_value ->
            let updated_grid = update_cell grid coord alpha_value in

            (* ensures no 3 or fewer isolated spots (orphans) are created *)
            if check_no_orphans updated_grid rows cols then

              (* keep track of which directions are valid for the next iteration *)
              let valid_directions =
                List.filter directions ~f:(fun dir ->
                    let new_coord = Coord.move coord dir in
                    Coord.in_bounds new_coord rows cols && is_free new_coord grid)
              in

              (* after zig-zag motion reaches the edge, we use choose from all directions *)
              let next_directions = if List.is_empty valid_directions then all_directions else valid_directions in

              
              (match List.random_element next_directions with
                | Some direction ->
                    let new_coord = Coord.move coord direction in
                    let updated_spangram_coords = coord :: spangram_coords in
                    let updated_map =
                      let existing_coords =
                        match WordCoords.find word map with
                        | Some coords -> coords
                        | None -> []
                      in
                      let position = (coord.y, coord.x) in
                      WordCoords.add word (existing_coords @ [position]) map
                    in
                    (* recursively place the remaining letters *)
                    place_letters updated_grid new_coord rest rows cols next_directions 100 updated_spangram_coords updated_map word
                | None ->
                    (* no valid direction: decrement retries and retry current letter *)
                    place_letters grid coord letters rows cols directions (retries - 1) spangram_coords map word)
              else
                (* grid state invalid: decrement retries and retry current letter *)
                place_letters grid coord letters rows cols directions (retries - 1) spangram_coords map word
            | Error _ ->
                (* failed to create an alpha value; fallback to retrying current letter *)
                place_letters grid coord letters rows cols directions (retries - 1) spangram_coords map word
          else
            (* cuurent position is invalid; decrement retries and retry current letter *)
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
    if retries <= 0 then 
      (grid, false, List.rev placed_positions) (* Return placed positions in order *)
    else
      match letters with
      | [] -> 
        if is_grid_full grid rows cols then
          (grid, true, List.rev placed_positions)
        else if check_no_orphans grid rows cols then
          (grid, true, List.rev placed_positions) (* All letters placed successfully *)
        else 
          (grid, false, List.rev placed_positions)
      | letter :: rest ->
        if Coord.in_bounds coord rows cols && is_free coord grid then
          match Alpha.make letter with (* Ensure letter is valid *)
          | Ok alpha_value ->
            let updated_grid = update_cell grid coord alpha_value in

            if List.is_empty rest && is_grid_full updated_grid rows cols then
              (updated_grid, true, List.rev (((coord.y, coord.x) : Position.t) :: placed_positions))
            else

              (* Entire word is not yet placed *)
              let valid_directions =
                List.filter directions ~f:(fun dir ->
                    let new_coord = Coord.move coord dir in
                    Coord.in_bounds new_coord rows cols && is_free new_coord updated_grid)
              in

              (* Filter from all directions *)
              let next_directions = 
                if List.is_empty valid_directions then 
                  List.filter all_directions ~f:(fun dir ->
                      let new_coord = Coord.move coord dir in
                      Coord.in_bounds new_coord rows cols && is_free new_coord updated_grid)
                else 
                  valid_directions
              in

              (* If no available directions, fallback *)
              if List.is_empty next_directions then 
                (match placed_positions with
                 | [] -> 
                   (grid, false, List.rev placed_positions) (* No fallback available *)
                 | (prev_y, prev_x) :: _ ->
                   let fallback_coord = 
                     Coord.move { Coord.x = prev_x; Coord.y = prev_y } (List.random_element_exn all_directions) 
                   in
                   attempt_place_word grid fallback_coord letters rows cols directions (retries - 1) placed_positions)                
              else
                let direction = List.random_element_exn next_directions in
                let new_coord = Coord.move coord direction in
                attempt_place_word updated_grid new_coord rest rows cols next_directions retries 
                  (((coord.y, coord.x) : Position.t) :: placed_positions)
          | Error _ -> 
            (grid, false, List.rev placed_positions) (* Skip invalid letters *)
        else
          (match placed_positions with
           | [] -> 
             (grid, false, List.rev placed_positions) (* No fallback available *)
           | (prev_y, prev_x) :: _ ->
             let fallback_coord = 
               Coord.move { Coord.x = prev_x; Coord.y = prev_y } (List.random_element_exn all_directions) 
             in
             attempt_place_word grid fallback_coord letters rows cols directions (retries - 1) placed_positions)


  let rec place_words_from_list grid words rows cols (word_coords : WordCoords.t) (is_vertical : bool) (check_orphans : bool) (second_attempt : string list) =
    match words with
    | [] -> (grid, word_coords, second_attempt) (* No more words to place, return the final grid *)
    | word :: rest ->
      match find_next_placement grid rows cols is_vertical with
      | None -> (grid, word_coords, second_attempt) (* No more open positions, return the current grid *)
      | Some coord ->
        (* Try to place the current word *)
        let (letters : char list) = String.to_list word in
        let (updated_grid, success, position_list) =
          attempt_place_word grid coord (letters : char list) rows cols word_placement_directions 50 []
        in
        if success then (* restart using vertical search *)
          (* Word placed successfully, move to the next word *)
          let word_coords = WordCoords.add word position_list word_coords in
          place_words_from_list updated_grid rest rows cols word_coords true check_orphans second_attempt
        else if is_vertical then (* try horizontal search *)
          (* Failed to place the word, try horizontal placement for the same word *)
          place_words_from_list grid words rows cols word_coords false check_orphans second_attempt
        else (* is_vertical is false, which means tried vertical and horizontal *)
          (* Skip the word but add to second attempt *)
          place_words_from_list grid rest rows cols word_coords true check_orphans (word :: second_attempt)

  let place_all_words words grid (word_coords : WordCoords.t) max_retries =
    let rows = List.length grid in
    let cols = List.length (List.hd_exn grid) in

    let rec attempt retries current_grid current_word_coords remaining_words =
      if retries = 0 || List.is_empty remaining_words then
        (current_grid, current_word_coords, remaining_words)
      else
        let (updated_grid, updated_word_coords, next_attempt_words) =
          (* Use true true for the first and second attempts, then true false for subsequent retries *)
          let (flag1, flag2) =
            if retries > max_retries - 3 then
              (true, true)  (* First and second retries *)
            else
              (true, false) (* Subsequent retries *)
          in
          place_words_from_list current_grid remaining_words rows cols current_word_coords flag1 flag2 []
        in
        attempt (retries - 1) updated_grid updated_word_coords next_attempt_words
    in

    attempt max_retries grid word_coords words


  let retry_place_all_words words grid (original_word_coords : WordCoords.t) =
    let rows = List.length grid in
    let cols = List.length (List.hd_exn grid) in

    let rec attempt original_grid word_coords retries =
      (* Ensure we don't run out of retries *)
      let (updated_grid, updated_word_coords, _) = place_all_words words original_grid word_coords 10 in

      (* Uncomment for debugging output *)
      (* Printf.printf "Trial Placement:\n";
         print_grid updated_grid; *)

      if is_grid_full updated_grid rows cols then 
        (updated_grid, updated_word_coords)
      else if retries = 0 then
        (updated_grid, word_coords)
      else
        (* Keep trying until the grid is full or retries are exhausted *)
        attempt original_grid word_coords (retries - 1)
    in

    (* Start the attempt with a set number of retries *)
    attempt grid original_word_coords 100
end

(* Word placement notes: Must be given a list of at least 15 words of varying lengths of at least 4 *)
let () =
  let grid = Grid.create_empty_grid 8 6 in
  let (grid_with_spangram, spangram_coords) = Grid.place_spangram "BLUEBERRY" grid in
  let (grid_with_words, word_coords) =
    Grid.retry_place_all_words
      ["1111"; "2222"; "33333"; "44444"; "555555"; "6666"; "77777"; "88888"; "999999";
       "XXXX"; "YYYYY"; "CCCCCC"; "DDDDDD"; "EEEEEEEE"; "FFFF"; "GGGGG"; "HHHHHH";
       "IIIIIII"; "JJJJ"; "KKKKK"; "LLLLLLL"; "MMMM"; "ZZZZZ"]
      grid_with_spangram
      spangram_coords
  in

  Printf.printf "Spangram Placement:\n";
  Grid.print_grid grid_with_spangram;

  Printf.printf "Spangram Coordinates (y, x)):\n";
  WordCoords.print_all_coords spangram_coords;

  Printf.printf "Word Placement:\n";
  Grid.print_grid grid_with_words;
  WordCoords.print_all_coords word_coords