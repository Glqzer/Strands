open Utils
open Grid
open Words

module Game = struct
  type config = {
    board: Grid.t;
    word_coords: WordCoords.t;
    spangram: string;
    theme: string
  }

  let initialize_game initial_state =
    (* fruits.txt - 6 letter spangram (BANANA) *)
    (* aniamals.txt - 8 letter spangram (CAPYBARA) *)
    let all_textfiles = ["fruits.txt"; "animals.txt"] in 
    let selected_file = List.nth all_textfiles (Random.int (List.length all_textfiles)) in

    let spangram = 
      try 
        parse_file selected_file
        |> get_spangram
      with 
      | _ -> failwith "Could not parse spangram from file"
    in

    let words = 
      try 
        parse_file selected_file
        |> get_words
      with 
      | _ -> failwith "Count not parse words from file" in 

    let empty_grid = Grid.create_empty_grid 8 6 in
    let (spangram_board, spangram_coords) = 
       Grid.place_spangram spangram empty_grid
    in
  
    let (board, word_coords) =
      Grid.retry_place_all_words words
        (* ["1111"; "2222"; "33333"; "44444"; "555555"; "6666"; "77777"; "88888"; "999999";
         "AAAA"; "BBBBB"; "CCCCCC"; "DDDDDD"; "EEEEEEEE"; "FFFF"; "GGGGG"; "HHHHHH";
         "IIIIIII"; "JJJJ"; "KKKKK"; "LLLLLLL"; "MMMM"; "NNNNN"; "OOOOOO"; "PPPPPPP";
         "QQQQ"; "RRRRR"; "SSSSS"] *)
        spangram_board
        spangram_coords
    in
  
    { initial_state with 
      board; 
      word_coords; 
      spangram; 
    }
  
  
  let check_word word coords state =
    check_result word coords state.word_coords

end