open Utils
open Words
open Game 
open Grid


let initial_state : Game.state = { 
  board = Grid.create_empty_grid 8 6; 
  word_coords = WordCoords.empty;
  word_records = WordRecord.empty; 
  spangram = ""
}
let game_state = Game.initialize_game initial_state



(* this is the static example *)
let static_state : Game.state = {
  board = static_grid;
  word_coords = static_coords;
  word_records = WordRecord.empty; 
  spangram = "functional"
}

let cors_headers = [
  ("Access-Control-Allow-Origin", "*");
  ("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  ("Access-Control-Allow-Headers", "Content-Type, Access-Control-Allow-Origin, Access-Control-Allow-Methods");
]

let handle_options (_ : Dream.request) =
    Dream.respond ~status:`OK ~headers:cors_headers ""

let create_board_response (state: Game.state) =
  `Assoc [("board", `List (
    state.board 
    |> List.map (fun row ->
      `List (List.map (fun alpha ->
        `String (String.make 1 (Alpha.show alpha))
      ) row)
    )
  ))]
  |> Yojson.Safe.to_string

let validate_word ~(state: Game.state) request =
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
      let is_valid = check_result word coords state.word_coords in
      let is_spangram = (word = state.spangram) in
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

let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [
    Dream.options "/initialize" handle_options;
    Dream.options "/validate" handle_options;

    Dream.get "/"
      (fun _ ->
        let response = 
          `Assoc [("message", `String "Good morning, world")]
          |> Yojson.Safe.to_string
        in
        Dream.respond ~headers:cors_headers response);

    Dream.get "/initialize" 
    (fun request ->
      let mode = Dream.query request "mode" |> Option.value ~default:"static" in
      let state = 
        match mode with
        | "static" -> static_state
        | "dynamic" -> game_state
        | _ -> static_state 
      in
      let response = create_board_response state in
      Dream.respond ~headers:cors_headers response);

    Dream.post "/validate"
      (fun request ->
        let mode = Dream.query request "mode" |> Option.value ~default:"static" in
        let state = 
          match mode with
          | "static" -> static_state
          | "dynamic" -> game_state
          | _ -> static_state 
        in
        validate_word ~state request
      );
]