open Core
open OUnit2

module Spangram_tests = struct
  (* Helper to check if all cells are empty (initial grid) *)
  let is_empty_grid grid =
    List.for_all grid ~f:(fun row ->
      List.for_all row ~f:(fun cell -> match cell with Alpha.Empty -> true | _ -> false))

  (* Test: Grid is initialized with all empty cells *)
  let test_create_empty_grid _ =
    let grid = Grid.create_empty_grid 8 6 in
    assert_bool "Grid should be empty" (is_empty_grid grid)

  (* Test: Check that a spangram is placed in bounds and no orphan regions are created *)
  let test_place_spangram _ =
    let grid = Grid.create_empty_grid 8 6 in
    let spangram = "blueberry" in
    let grid_with_spangram = Grid.place_spangram spangram grid in

    (* Check if grid has no orphan regions after spangram placement *)
    assert_bool "Grid should not contain orphan regions" (Grid.check_no_orphans grid_with_spangram 8 6);

    (* Check that all letters in the spangram are placed (letters should be filled) *)
    let letters = String.to_list spangram in
    let positions = List.concat_map letters ~f:(fun letter ->
      let positions = List.filter_mapi grid_with_spangram ~f:(fun y row ->
        List.find_mapi row ~f:(fun x cell ->
          if Alpha.show cell = letter then Some { Coord.x; y } else None
        )
      ) in
      positions) in
    assert_equal (List.length positions) (String.length spangram) ~msg:"Not all spangram letters are placed"

  (* Test: Spangram placement respects grid boundaries (no out-of-bounds placement) *)
  let test_spangram_fits_within_grid _ =
    let grid = Grid.create_empty_grid 8 6 in
    let spangram = "blueberry" in
    let grid_with_spangram = Grid.place_spangram spangram grid in

    (* Check if the grid has no out-of-bounds coordinates for the spangram *)
    let is_within_bounds { Coord.x; y } =
      x >= 0 && x < 6 && y >= 0 && y < 8
    in
    let letters = String.to_list spangram in
    let positions = List.concat_map letters ~f:(fun letter ->
      let positions = List.filter_mapi grid_with_spangram ~f:(fun y row ->
        List.find_mapi row ~f:(fun x cell ->
          if Alpha.show cell = letter then Some { Coord.x; y } else None
        )
      ) in
      positions) in
    List.iter positions ~f:(fun pos ->
      assert_bool "Spangram letter should be within grid bounds" (is_within_bounds pos))

  (* Test: Test placement of an empty spangram (edge case) *)
  let test_place_empty_spangram _ =
    let grid = Grid.create_empty_grid 8 6 in
    let grid_with_empty_spangram = Grid.place_spangram "" grid in
    (* Ensure that the grid has not changed *)
    assert_bool "Grid should be unchanged for empty spangram" (is_empty_grid grid_with_empty_spangram)

end

let series =
  "Spangram tests" >:::
  [
    "Test grid initialization" >:: Spangram_tests.test_create_empty_grid;
    "Test spangram placement" >:: Spangram_tests.test_place_spangram;
    "Test spangram placement within grid bounds" >:: Spangram_tests.test_spangram_fits_within_grid;
    "Test empty spangram" >:: Spangram_tests.test_place_empty_spangram;
  ]

let () = run_test_tt_main series
