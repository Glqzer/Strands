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
    
    let empty_grid = Grid.create_empty_grid 8 6 in
    let (spangram_board, spangram_coords) = 
       Grid.place_spangram spangram empty_grid
    in
  
    let (board, word_coords) =
      Grid.retry_place_all_words
        ["1111"; "2222"; "33333"; "44444"; "555555"; "6666"; "77777"; "88888"; "999999";
         "AAAA"; "BBBBB"; "CCCCCC"; "DDDDDD"; "EEEEEEEE"; "FFFF"; "GGGGG"; "HHHHHH";
         "IIIIIII"; "JJJJ"; "KKKKK"; "LLLLLLL"; "MMMM"; "NNNNN"; "OOOOOO"; "PPPPPPP";
         "QQQQ"; "RRRRR"; "SSSSS"]
        spangram_board
        30
        spangram_coords
    in
  
    { initial_state with 
      board; 
      word_coords; 
      spangram; 
    }
  
  

  let check_word word coords state =
    check_result word coords state.word_coords

  let set_found word state =
    let updated_word_records = Words.set_found word state.word_records in
    { state with word_records = updated_word_records }

end