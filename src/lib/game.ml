[@@@ocaml.warning "-27"]

open Utils
open Grid
open Words


module Game = struct

  type state = {
    board: Grid.t;
    word_coords: WordCoords.t;
    word_records: WordRecord.t;
  }

  let initialize_game state =

    (* initalize the board *)
    let spangram =
      parse_file "sample_words.txt"
      |> get_spangram in

    let board =
      Grid.create_empty_grid 8 6 
      |> Grid.place_spangram spangram in

    {state with board}

    (* TODO add a function that fetches the word coords from Grid *)


  let check_word word coords state  = 
    check_result word coords state.word_coords 

  let set_found word state =
    let updated_word_records = Words.set_found word state.word_records in
    { state with word_records = updated_word_records }

  
  end


