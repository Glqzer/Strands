(* open Core *)

module Grid = struct
  (* type t = char list list *)

  (* initalized an empty grid, both rows and columns have default '-' *)
  (* let create_empty_grid (rows : int) (cols : int) : t =
    List.init rows ~f:(fun _ -> List.init cols ~f:(fun _ -> '-')) *)

  (* list of directions to help place each letter of the spangram *)
  (* let directions = [
    (* --- BASIC --- *)
    (* up, down, left, right *)
    (-1, 0); (1, 0); (0, -1);(0, 1);   

    (* --- DIAGONALS ---  *)
    (* up-left, up-right, down-left, down-right *)
    (-1, -1); (-1, 1); (1, -1); (1, 1);   
  ] *)

  (* place the spangram on a vertical-like path, starting at a random column *)
  (* let vertical_span (spangram : string) (rows : int) (cols : int) : t = *)
    (* --- SET UP ---  *)
    (* let letters = Utils.split_into_letters spangram in
    let span_len = List.length letters in
    let grid = create_empty_grid rows cols in 
    let starting_col = Random.int cols in   *)

    (* using recursion to place all of the letters on new grid until there's no more letters *)
    (* let rec place_letters letters grid = 
      match letters with 
    | [] -> grid 
    | letter :: rest ->  *)
      (* choose a direction to place a letter -- random *)
      (* let next_dir = Random.int (List.length directions) in  *)

      (* check valid position -- if its in bounds and not overlap *)
      
      (* make a new grid and recurse until all letters are placed well *)
      (* make sure it spans the grid  *)
      




  (* place the spangram on the grid (vertical or horizontal) *)
  (* let generate_spangram (spangram: string) : t = 
    let rows = 8 in 
    let cols = 6 in  
    (* TODO: randomize between vertical or horizontal span -- will use Random *)
    vertical_span spangram rows cols *)

  (* Print out the grid *)
  (* let print_grid (grid : t) : unit =
    List.iter grid ~f:(fun row ->
      List.iter row ~f:(fun col -> Printf.printf "%c " col);  
      Printf.printf "\n")  *)
end

(* Print testing, shown in dune utop *)
(* let () = 
  let spangram = "blueberr" in 
  let grid_with_spangram = Grid.place_spangram spangram in 
  Grid.print_grid grid_with_spangram *)
