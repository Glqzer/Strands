open Utils
open Words
open Game 
open Grid


let initial_state : Game.state = { 
  board = Grid.create_empty_grid 8 6; 
  word_coords = (
    let open WordCoords in
    empty
    |> add "apple" [(6, 0); (7, 0); (7, 1); (7, 2); (6, 2)]
    |> add "blueberry" [(0, 1); (0, 2); (1, 3); (2, 3); (3, 2); (4, 3); (5, 3); (6, 3); (7, 3)]
  ); 
  word_records = WordRecord.empty; 
  spangram = ""
}

(* this is the static example *)
let static_state : Game.state = {
  board = static_grid;
  word_coords = (
    let open WordCoords in
    empty
    |> add "apple" [(6, 0); (7, 0); (7, 1); (7, 2); (6, 2)]
    |> add "blueberry" [(0, 1); (0, 2); (1, 3); (2, 3); (3, 2); (4, 3); (5, 3); (6, 3); (7, 3)]
  ); 
  word_records = WordRecord.empty; 
  spangram = "functional"
}

let game_state = Game.initialize_game initial_state

let cors_headers = [
  ("Access-Control-Allow-Origin", "*");
  ("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  ("Access-Control-Allow-Headers", "Content-Type, Access-Control-Allow-Origin, Access-Control-Allow-Methods");
]

let handle_options (_ : Dream.request) =
    Dream.respond ~status:`OK ~headers:cors_headers ""
      
let () =
  Dream.run
  @@ Dream.logger
    
  @@ Dream.router [
    Dream.options "/initialize-static" handle_options;
    Dream.options "/initialize-dynamic" handle_options;
    Dream.options "/validate" handle_options;

    Dream.get "/"
      (fun _ ->
        let response = 
          `Assoc [("message", `String "Good morning, world")]
          |> Yojson.Safe.to_string
        in
        Dream.respond ~headers:cors_headers response);

    Dream.get "/initialize-static" 
    (fun _ ->
      let board = static_state.board in
      let response = `Assoc [("board", `List (
        board 
        |> List.map (fun row ->
          `List (List.map (fun alpha ->
            `String (String.make 1 (Alpha.show alpha))
          ) row)
        )
      ))]
      
      |> Yojson.Safe.to_string
      in 
      Dream.respond ~headers:cors_headers response);

      Dream.get "/initialize-dynamic" 
      (fun _ ->
        
        let board = 
          Grid.create_empty_grid 8 6 |>
          Grid.place_spangram "banana"
         in  
        let response = `Assoc [("board", `List (
          board 
          |> List.map (fun row ->
            `List (List.map (fun alpha ->
              `String (String.make 1 (Alpha.show alpha))
            ) row)
          )
        ))]
        
        |> Yojson.Safe.to_string
        in 
        Dream.respond ~headers:cors_headers response);

    Dream.post "/validate"
      (fun request ->
        Lwt.bind (Dream.body request) (fun body ->
          try 
            let json = Yojson.Safe.from_string body in
            let open Yojson.Safe.Util in
            let word = json |> member "word" |> to_string in
            let coords = 
              json 
              |> member "coordinates" 
              |> to_list 
              |> List.map (fun coord -> 
                let row = coord |> member "row" |> to_int in
                let col = coord |> member "col" |> to_int in
                (row, col)
              )
            in
            let is_valid = check_result word coords game_state.word_coords in
            let is_spangram = (word = game_state.spangram) in
            let response = 
              `Assoc [
                ("word", `String word);
                ("isValid", `Bool is_valid);
                ("isSpangram", `Bool is_spangram)
              ]
              |> Yojson.Safe.to_string 
            in
            Dream.respond ~headers:cors_headers response;
          with 
          | _ -> 
            Dream.respond 
              ~status:`Bad_Request 
              ~headers:cors_headers 
              {|{"error": "Invalid request"}|}
        )
      );
]
