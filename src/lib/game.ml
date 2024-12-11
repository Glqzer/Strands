open Utils
open Grid
open Words

module Game = struct
  type config = {
    board: Grid.t;
    word_coords: WordCoords.t;
    word_records: WordRecord.t;
    spangram: string;
    theme: string
  }

  let initialize_game initial_state =
    let spangram = 
      try 
        parse_file "sample_words.txt" 
        |> get_spangram
      with 
      | _ -> failwith "Could not parse spangram from file"
    in
    
    let board = 
      Grid.create_empty_grid 8 6 
      |> Grid.place_spangram spangram |> fst
    in
    
    (* TO-DO get word coords *)
    
    { initial_state with 
      board; 
      spangram;
    }

  let check_word word coords state =
    check_result word coords state.word_coords

  let set_found word state =
    let updated_word_records = Words.set_found word state.word_records in
    { state with word_records = updated_word_records }

end