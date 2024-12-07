open Core
open OUnit2
open Grid

(* bisect-ppx-report html *)

module Alpha_tests = struct
  let test_make_alpha _ =
    assert_equal (Alpha.make 'T') (Ok (Alpha.Filled 'T'));
    assert_equal (Alpha.make '9') (Ok (Alpha.Filled '9')); (* we won't use numbers, but test in case *)
    assert_equal (Alpha.make '!') (Error "not an alphanumeric character!")
  let test_show_alpha _ =
    assert_equal (Alpha.show (Alpha.Filled 'M')) 'M';
    assert_equal (Alpha.show Alpha.Empty) '-'

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
    assert_equal (Coord.move coord `Up) { Coord.x = 2; y = 1 };
    assert_equal (Coord.move coord `Down) { Coord.x = 2; y = 3 };
    assert_equal (Coord.move coord `Left) { Coord.x = 1; y = 2 };
    assert_equal (Coord.move coord `Right) { Coord.x = 3; y = 2 }
    (* TODO: put assert equals for diagonal movements *)
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

  let test_place_empty_spangram _ =
    let grid = Grid.create_empty_grid 8 6 in
    let grid_with_empty_spangram = Grid.place_spangram "" grid in
    assert_bool "grid should be unchanged for empty spangram" (is_empty_grid grid_with_empty_spangram)

  (* test: updating a cell in the grid *)
  let test_update_cell _ =
    let grid = Grid.create_empty_grid 8 6 in
    let coord = { Coord.x = 2; y = 3 } in
    let updated_grid = Grid.update_cell grid coord (Alpha.Filled 'T') in
    match Grid.get_cell updated_grid coord with
    | Some (Alpha.Filled c) -> assert_equal c 'T'
    | _ -> assert_failure "cell should be updated to 'T'"

  let test_spangram_in_bounds _ =
    let grid = Grid.create_empty_grid 8 6 in
    let spangram = "test" in
    let grid_with_spangram = Grid.place_spangram spangram grid in
    let rows = List.length grid in
    let cols = List.length (List.hd_exn grid) in
    List.iteri grid_with_spangram ~f:(fun y row ->
        List.iteri row ~f:(fun x cell ->
            match cell with
            | Alpha.Filled _ -> assert_bool "Filled cell should be in bounds" (Coord.in_bounds { Coord.x = x; y } rows cols)
            | _ -> ()))
end

(* test suite that combines all testings modules, very clean :D *)
let series =
  "Strands Tests" >:::
  [
    (* Alpha tests *)
    "test make alpha" >:: Alpha_tests.test_make_alpha;
    "test show alpha" >:: Alpha_tests.test_show_alpha;

    (* Coord tests *)
    "test coord in bounds" >:: Coord_tests.test_in_bounds;
    "test coord equality" >:: Coord_tests.test_coord_equal;
    "test coord move" >:: Coord_tests.test_move_coord;

    (* Grid tests *)
    "test grid initialization" >:: Grid_tests.test_create_empty_grid;
    "test place empty spangram" >:: Grid_tests.test_place_empty_spangram;
    "test update cell" >:: Grid_tests.test_update_cell;
    "test spangram in bounds" >:: Grid_tests.test_spangram_in_bounds;
  ]

let () = run_test_tt_main series

