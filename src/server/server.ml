open Utils
open Words
open Game 
open Grid

(* this is the hard-coded static example *)
let static_config : Game.config = {
  board = static_grid;
  word_coords = static_coords;
  spangram = "functional";
  theme = "let('s) strand"
}

let cors_headers = [
  ("Access-Control-Allow-Origin", "*");
  ("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  ("Access-Control-Allow-Headers", "Content-Type, Access-Control-Allow-Origin, Access-Control-Allow-Methods");
]

let handle_options (_ : Dream.request) =
    Dream.respond ~status:`OK ~headers:cors_headers ""
    
let print_coords (config : Game.config) = 
  let coords_json =
    config.word_coords
    |> WordCoords.bindings 
    |> List.map (fun (word, coords) ->
      `Assoc [
        ("word", `String word);
        ("coordinates", `List (
          coords
          |> List.map (fun (row, col) -> 
            `Assoc [
              ("row", `Int row);
              ("col", `Int col)
            ]
          )
        ))
      ]
    ) in
    coords_json

    
    let create_board_response (config: Game.config) =
      let coords_json = print_coords config
      in
      `Assoc [
        ("board", `List (
          config.board 
          |> List.map (fun row -> 
            `List (List.map (fun alpha -> 
              `String (String.make 1 (Alpha.show alpha))
            ) row)
          )
        ));
        ("theme", `String config.theme);
        ("coords", `List coords_json) 
      ]
      |> Yojson.Safe.to_string
    

      let validate_word ~(config: Game.config) request =
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
            let coords_json = print_coords config in
            let is_valid = check_result word coords config.word_coords in
            let is_spangram = (word = config.spangram) in
            let response = 
              `Assoc [
                ("word", `String word);
                ("isValid", `Bool is_valid);
                ("isSpangram", `Bool is_spangram);
                ("coords", `List coords_json)
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


let dynamic_config = ref (Some static_config)

let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [
    Dream.options "/initialize" handle_options;
    Dream.options "/validate" handle_options;
    Dream.options "/initialize-playground" handle_options;

    Dream.get "/"
      (fun _ ->
        let response = 
          `Assoc [("message", `String "Hello, world")]
          |> Yojson.Safe.to_string
        in
        Dream.respond ~headers:cors_headers response);

    Dream.get "/initialize" 
    (fun request ->
      let mode = Dream.query request "mode" |> Option.value ~default:"static" in
      
      let state = 
        match mode with
        | "static" -> 
            dynamic_config := Some static_config;
            static_config
        | "dynamic" -> 
            let config : Game.config = { 
              board = Grid.create_empty_grid 8 6; 
              word_coords = WordCoords.empty;
              spangram = "";
              theme = "dynamic strands"
            } in
            let game_config = Game.initialize_game config in
            dynamic_config := Some game_config;
            game_config
        | _ -> static_config 
      in
      
      let response = create_board_response state in
      Dream.respond ~headers:cors_headers response);

      Dream.post "/initialize-playground" 
      (fun request -> 
        Lwt.bind (Dream.body request) (fun body ->
          try
            let json = Yojson.Safe.from_string body in
            let open Yojson.Safe.Util in
            let theme = json |> member "theme" |> to_string_option |> Option.value ~default:"playground theme" in
            let spangram = json |> member "spangram" |> to_string_option |> Option.value ~default:"" in
            let (board, word_coords) = Grid.create_empty_grid 8 6 |> Grid.place_spangram spangram in
            let config : Game.config = {
              board = board;
              word_coords = word_coords;
              spangram = spangram;
              theme = theme;
            } in
      
            dynamic_config := Some config;
            
            let response = create_board_response config in
             (Dream.respond ~headers:cors_headers response)
          with
          | _ -> 
             (
              Dream.respond 
                ~status:`Bad_Request 
                ~headers:cors_headers 
                {|{"error": "Invalid request"}|}
            )
        )
      );

    Dream.post "/validate"
      (fun request ->
        let mode = Dream.query request "mode" |> Option.value ~default:"static" in
        let config = 
          match mode with
          | "static" -> static_config
          | _ -> 
              (match !dynamic_config with
              | Some state -> state
              | None -> static_config)
        in
        validate_word ~config request
      );
]