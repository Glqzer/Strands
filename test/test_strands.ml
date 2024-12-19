open Core
open OUnit2
open Grid
open Words
open Utils

module Alpha_tests = struct
  let test_make_alpha _ =
    assert_equal (Alpha.make 'T') (Ok (Alpha.Filled 'T'));
    assert_equal (Alpha.make '9') (Ok (Alpha.Filled '9')); (* we won't use numbers, but test in case *)
    assert_equal (Alpha.make '!') (Error "not an alphanumeric character!")

  let test_show_alpha _ =
    assert_equal (Alpha.show (Alpha.Filled 'M')) 'M';
    assert_equal (Alpha.show Alpha.Empty) '-'

  let test_invalid_char _ =
    match Alpha.make '!' with
    | Ok _ -> assert_failure "should reject non-alphanumeric character"
    | Error _ -> ()

end

module Coord_tests = struct
  let test_in_bounds _ =
    let rows, cols = 8, 6 in
    let valid_coord = { Coord.x = 5; y = 4 } in
    let invalid_coord = { Coord.x = 9; y = -1 } in
    assert_bool "valid coord should be in bounds" (Coord.in_bounds valid_coord rows cols);
    assert_bool "invalid coord should be out of bounds" (not (Coord.in_bounds invalid_coord rows cols))

  let test_coord_equal _ =
    let coord1 = { Coord.x = 3; y = 4 } in
    let coord2 = { Coord.x = 3; y = 4 } in
    let coord3 = { Coord.x = 4; y = 3 } in
    assert_bool "coords should be equal" (Coord.equal coord1 coord2);
    assert_bool "coords should not be equal" (not (Coord.equal coord1 coord3))

  let test_move_coord _ =
    let coord = { Coord.x = 2; y = 2 } in
    (* basic movements *)
    assert_equal (Coord.move coord `Up) { Coord.x = 2; y = 1 };
    assert_equal (Coord.move coord `Down) { Coord.x = 2; y = 3 };
    assert_equal (Coord.move coord `Left) { Coord.x = 1; y = 2 };
    assert_equal (Coord.move coord `Right) { Coord.x = 3; y = 2 };

    (* diagonal movements *)
    assert_equal (Coord.move coord `UpLeft) { Coord.x = 1; y = 1 };
    assert_equal (Coord.move coord `UpRight) { Coord.x = 3; y = 1 };
    assert_equal (Coord.move coord `DownLeft) { Coord.x = 1; y = 3 };
    assert_equal (Coord.move coord `DownRight) { Coord.x = 3; y = 3 }

end

module Grid_tests = struct
  (* helper to check if all cells are empty (initial grid) *)
  let is_empty_grid grid =
    List.for_all grid ~f:(fun row ->
        List.for_all row ~f:(fun cell -> 
            match cell with 
            | Alpha.Empty -> true 
            | _ -> false
          ))

  let test_create_empty_grid _ =
    let grid = Grid.create_empty_grid 8 6 in
    assert_bool "this grid should be empty" (is_empty_grid grid)

  let test_get_empty_cell _ =
    let grid = Grid.create_empty_grid 8 6 in
    let coord = { Coord.x = 5; y = 5 } in
      match Grid.get_cell grid coord with
      | Some Alpha.Empty -> ()  
      | _ -> assert_failure "expected cell to be empty"
  
  let test_is_free _ = 
    let grid = Grid.create_empty_grid 8 6 in 
    let coord = { Coord.x = 5; y = 5 } in 
      match Grid.is_free coord grid with 
      | true -> ()
      | _ -> assert_failure "expected any coord here to be free"

  let test_update_cell _ =
    let grid = Grid.create_empty_grid 8 6 in
    let coord = { Coord.x = 2; y = 3 } in
    let updated_grid = Grid.update_cell grid coord (Alpha.Filled 'T') in
    match Grid.get_cell updated_grid coord with
    | Some (Alpha.Filled c) -> assert_equal c 'T'
    | _ -> assert_failure "cell should be updated to 'T'"

  let test_grid_boundaries _ =
    let grid = Grid.create_empty_grid 2 2 in
    let coord = { Coord.x = 1; y = 1 } in
    let updated_grid = Grid.update_cell grid coord (Alpha.Filled 'A') in
    assert_bool
      "Cell at boundary should be updated"
      (match Grid.get_cell updated_grid coord with
        | Some (Alpha.Filled 'A') -> true
        | _ -> false)

    let test_corner_placement _ =
      let grid = Grid.create_empty_grid 3 3 in
      let corner = { Coord.x = 0; y = 0 } in
      let updated_grid = Grid.update_cell grid corner (Alpha.Filled 'B') in
      assert_bool
        "Corner cell should be fillable"
        (match Grid.get_cell updated_grid corner with
          | Some (Alpha.Filled 'B') -> true
          | _ -> false)

  (* improving code coverage: `check_cell` function's fallback case `| _ -> false` *)
  let test_check_cell_false _ =
    let grid = Grid.create_empty_grid 8 6 in
    let coord = { Coord.x = 2; y = 2 } in
    let updated_grid = Grid.update_cell grid coord (Alpha.Filled 'A') in
    assert_bool
      "check_cell should return false for a filled cell"
      (not (Grid.check_no_orphans updated_grid coord.x coord.y))

  let test_orphan_pattern _ =
    let grid = Grid.create_empty_grid 8 6 in
    (* creates a pattern that would isolate a small region of empty cells *)
    let grid = Grid.update_cell grid { Coord.x = 2; y = 2 } (Alpha.Filled 'T') in
    let grid = Grid.update_cell grid { Coord.x = 3; y = 2 } (Alpha.Filled 'A') in
    let grid = Grid.update_cell grid { Coord.x = 2; y = 3 } (Alpha.Filled 'Y') in
    let grid = Grid.update_cell grid { Coord.x = 3; y = 3 } (Alpha.Filled 'L') in
    let grid = Grid.update_cell grid { Coord.x = 2; y = 4 } (Alpha.Filled 'O') in
    let grid = Grid.update_cell grid { Coord.x = 3; y = 4 } (Alpha.Filled 'R') in
    
    (* this creates a pattern that isolates a region of 3 cells *)
    assert_bool
      "detects orphan pattern in 8x6 grid"
      (Grid.check_no_orphans grid 8 6)

  let test_place_spangram_vertical _ =
    let grid = Grid.create_empty_grid 8 6 in
    let spangram = "RAMBUTAN" in
    let (updated_grid, word_coords) = Grid.place_spangram spangram grid in
    
    (* count filled cells by folding over the grid *)
    let count_filled_cells grid =
      List.fold grid ~init:0 ~f:(fun acc row ->
        acc + List.count row ~f:(function
          | Alpha.Filled _ -> true
          | Alpha.Empty -> false))
    in
    
    let filled_count = count_filled_cells updated_grid in
    assert_equal ~msg:"all spangram letters should be placed" 
      (String.length spangram) filled_count;
      
    (* checks that spangram coordinates were recorded *)
    let coords_length = 
      WordCoords.find spangram word_coords
      |> Option.value_map ~default:0 ~f:List.length
    in
    assert_equal ~msg:"should have coordinates for each letter"
      (String.length spangram) coords_length;
  
    (* verify no orphan regions were created *)
    assert_bool 
      "no orphan regions should exist after placing spangram"
      (Grid.check_no_orphans updated_grid 8 6)

  let test_place_spangram_horizontal _ =
    let grid = Grid.create_empty_grid 8 6 in
    let spangram = "BANANA" in
    let (updated_grid, word_coords) = Grid.place_spangram spangram grid in

    (* count filled cells by folding over the grid *)
    let count_filled_cells grid =
      List.fold grid ~init:0 ~f:(fun acc row ->
        acc + List.count row ~f:(function
          | Alpha.Filled _ -> true
          | Alpha.Empty -> false))
    in

    let filled_count = count_filled_cells updated_grid in
    assert_equal ~msg:"all spangram letters should be placed"
      (String.length spangram) filled_count;

    (* checks that spangram coordinates were recorded *)
    let coords_length = 
      WordCoords.find spangram word_coords
      |> Option.value_map ~default:0 ~f:List.length
    in
    assert_equal ~msg:"should have coordinates for each letter"
      (String.length spangram) coords_length;

    assert_bool 
      "no orphan regions should exist after placing spangram"
      (Grid.check_no_orphans updated_grid 8 6)
  
  (* trying to improve code coverage: seven lettered spangram can go either vertical or horizontal *)
  (* i am testing the random case -->  if Random.bool () then `Vertical else `Horizontal *)
  (*let test_place_spangram_seven_letters _ =
    let grid = Grid.create_empty_grid 8 6 in
    let spangram = "BRANDON" in
    let (updated_grid, word_coords) = Grid.place_spangram spangram grid in
    let count_filled_cells grid =
      List.fold grid ~init:0 ~f:(fun acc row ->
        acc + List.count row ~f:(function
          | Alpha.Filled _ -> true
          | Alpha.Empty -> false))
    in

    let filled_count = count_filled_cells updated_grid in
    assert_equal ~msg:"all spangram letters should be placed"
      (String.length spangram) filled_count;

    let coords_length = 
      WordCoords.find spangram word_coords
      |> Option.value_map ~default:0 ~f:List.length
    in
    assert_equal ~msg:"should have coordinates for each letter" (String.length spangram) coords_length;
    assert_bool "no orphan regions should exist after placing spangram" (Grid.check_no_orphans updated_grid 8 6)*)

  let test_word_placement_in_bounds _ = 
    let grid = Grid.create_empty_grid 8 6 in
    let words = ["1111"; "2222"; "33333"; "44444"; "555555"; "6666"; "77777"; "88888"; "999999";
                 "XXXX"; "YYYYY"; "CCCCCC"; "DDDDDD"; "EEEEEEEE"; "FFFF"; "GGGGG"; "HHHHHH";
                 "IIIIIII"; "JJJJ"; "KKKKK"; "LLLLLLL"; "MMMM"; "ZZZZZ"] in
    let (grid_with_words, _) = Grid.retry_place_all_words words grid WordCoords.empty in
    let rows = List.length grid in
    let cols = List.length (List.hd_exn grid) in
    List.iteri grid_with_words ~f:(fun y row ->
        List.iteri row ~f:(fun x cell ->
            match cell with
            | Alpha.Filled _ -> assert_bool "Filled cell should be in bounds" (Coord.in_bounds { Coord.x = x; y } rows cols)
            | _ -> ()))

  let test_final_placement_full_grid _ = 
    let grid = Grid.create_empty_grid 8 6 in
    let words = ["1111"; "2222"; "33333"; "44444"; "555555"; "6666"; "77777"; "88888"; "999999";
                 "XXXX"; "YYYYY"; "CCCCCC"; "DDDDDD"; "EEEEEEEE"; "FFFF"; "GGGGG"; "HHHHHH";
                 "IIIIIII"; "JJJJ"; "KKKKK"; "LLLLLLL"; "MMMM"; "ZZZZZ"] in
    let (grid_with_words, _) = Grid.retry_place_all_words words grid WordCoords.empty in
    let rows = List.length grid in
    let cols = List.length (List.hd_exn grid) in
    assert_bool "Grid must be full" (Grid.is_grid_full grid_with_words rows cols)

  (* Check if all letters in the given list of coordinates are adjacent *)
  let validate_word_adjacency (word_coords : WordCoords.t) =
    (* Check adjacency for all coordinates of each word *)
    let rec are_letters_adjacent coords =
      match coords with
      | [] | [_] -> true (* Single or no coordinate is valid *)
      | (x1, y1) :: (x2, y2) :: rest ->
        let dx = abs (x2 - x1) in
        let dy = abs (y2 - y1) in
        if dx <= 1 && dy <= 1 then are_letters_adjacent ((x2, y2) :: rest)
        else false
    in
    (* Iterate over all bindings in the map *)
    let validate_all bindings =
      List.for_all ~f:(fun (_word, coords) -> are_letters_adjacent coords) bindings
    in
    validate_all (WordCoords.bindings word_coords)

  let test_validate_word_adjacency _ =
    let open WordCoords in
    let map =
      WordCoords.empty
      |> add "word1" [(0, 0); (0, 1); (0, 2)]  (* Adjacent horizontally *)
      |> add "word2" [(1, 0); (2, 0); (3, 0)]  (* Adjacent vertically *)
      |> add "word3" [(3, 3); (4, 4); (5, 5)]  (* Adjacent diagonally *)
      |> add "word4" [(0, 0); (2, 0); (4, 0)]  (* Not adjacent *)
    in
    assert_bool "Should not validate unadjacent words" (not (validate_word_adjacency map)) (* Should return false *)

  let test_word_coords_adjacent _ =
    let grid = Grid.create_empty_grid 8 6 in
    let words = ["1111"; "2222"; "33333"; "44444"; "555555"; "6666"; "77777"; "88888"; "999999";
                 "XXXX"; "YYYYY"; "CCCCCC"; "DDDDDD"; "EEEEEEEE"; "FFFF"; "GGGGG"; "HHHHHH";
                 "IIIIIII"; "JJJJ"; "KKKKK"; "LLLLLLL"; "MMMM"; "ZZZZZ"] in
    let (_, word_coords) = Grid.retry_place_all_words words grid WordCoords.empty in
    assert (validate_word_adjacency word_coords)

end

module Word_tests = struct

  let test_word_coords _ =
    let open WordCoords in
    let coords = [(1, 1); (2, 2)] in
    let map = 
      empty 
      |> add "hello" coords 
      |> add "world" [(3, 3); (4, 4)]
    in
    (* Test find *)
    assert_equal (find "hello" map) (Some coords);
    assert_equal (find "world" map) (Some [(3, 3); (4, 4)]);
    assert_equal (find "missing" map) None


  let test_check_result _ =
    let open WordCoords in
    let coords = [(1, 1); (2, 2)] in
    let map = empty |> add "hello" coords in
    (* Matching coords *)
    assert_bool "Matching coords" (check_result "hello" coords map);
    (* Non-matching coords *)
    assert_bool "Non-matching coords" (not (check_result "hello" [(3, 3)] map));
    (* Word not in map *)
    assert_bool "Word not in map" (not (check_result "missing" coords map))

end

module Utils_tests = struct

  let test_get_spangram _ =
    (* Test with a non-empty list *)
    let words = ["spangram"; "word1"; "word2"] in
    let spangram = get_spangram words in
    assert_equal "spangram" spangram;

    (* Test with an empty list *)
    let empty_words = [] in
    let spangram_empty = get_spangram empty_words in
    assert_equal "" spangram_empty

  let test_get_words _ =
    (* Test with a non-empty list *)
    let words = ["spangram"; "word1"; "word2"] in
    let themed_words = get_words words in
    assert_equal ["word1"; "word2"] themed_words;

    (* Test with an empty list *)
    let empty_words = [] in
    let themed_words_empty = get_words empty_words in
    assert_equal [] themed_words_empty;

    (* Test with a list containing only the spangram *)
    let single_word = ["spangram"] in
    let themed_words_single = get_words single_word in
    assert_equal [] themed_words_single

end

(* test suite that combines all testings modules, very clean :D *)
let series =
  "Strands Tests" >:::
  [
    (* Alpha tests *)
    "test make alpha" >:: Alpha_tests.test_make_alpha;
    "test show alpha" >:: Alpha_tests.test_show_alpha;
    "test invalid char" >:: Alpha_tests.test_invalid_char;

    (* Coord tests *)
    "test coord in bounds" >:: Coord_tests.test_in_bounds;
    "test coord equality" >:: Coord_tests.test_coord_equal;
    "test coord move" >:: Coord_tests.test_move_coord;

    (* Grid tests *)
    "test grid initialization" >:: Grid_tests.test_create_empty_grid;
    "test grid get empty cell" >:: Grid_tests.test_get_empty_cell;
    "test grid update cell" >:: Grid_tests.test_update_cell;
    "test grid boundaries" >:: Grid_tests.test_grid_boundaries;
    "test grid corner placement" >:: Grid_tests.test_corner_placement;
    "test grid check cell on false case" >:: Grid_tests.test_check_cell_false;
    "test grid is free" >:: Grid_tests.test_is_free;
    "test grid orphan pattern" >:: Grid_tests.test_orphan_pattern;
    "test place spangram vertical" >:: Grid_tests.test_place_spangram_vertical;
    "test place spangram horizontal" >:: Grid_tests.test_place_spangram_horizontal;
    (* "test place spangram seven letters" >:: Grid_tests.test_place_spangram_seven_letters; *)
    "test word placement in bounds" >:: Grid_tests.test_word_placement_in_bounds;
    "test word placement fills grid" >:: Grid_tests.test_final_placement_full_grid;
    "test word adjacency validation" >:: Grid_tests.test_validate_word_adjacency;
    "test word adjacency in grid" >:: Grid_tests.test_word_coords_adjacent;

    (* Word tests *)
    "test_word_coords" >:: Word_tests.test_word_coords;
    "test_check_result" >:: Word_tests.test_check_result;

    (* Utils tests *)
    "test_get_spangram" >:: Utils_tests.test_get_spangram;
    "test_get_words" >:: Utils_tests.test_get_words;

  ]

let () = run_test_tt_main series

