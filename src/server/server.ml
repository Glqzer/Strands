open Utils
open Words
(* open Grid *)


let solution_coords = 
  let open WordCoords in
  empty
  |> add "apple" [(6, 0); (7, 0); (7, 1); (7, 2); (6, 2)]


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
    (fun _ ->
      (* THIS SECTION IS FOR POPULATING THE FRONT-END WITH THE OUTPUT OF OUR GRID CREATION FUNCTIONS*)
      
      (* let initial_grid = Grid.create_empty_grid 8 6 in
      let spangram = "blueberry" in 
      let board_with_spangram = Grid.place_spangram spangram initial_grid in
  
      let response = `Assoc [("board", `List (
        board_with_spangram 
        |> List.map (fun row ->
          `List (List.map (fun alpha ->
            `String (String.make 1 (Alpha.show alpha))
          ) row)
        )
      ))] *)

      
      let board = sample_grid in
      let response = `Assoc [("board", `List (
        List.map (fun row ->
          `List (List.map (fun c -> `String (String.make 1 c)) row)
        ) board
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
            let is_valid = check_result word coords solution_coords in
            let response = 
              `Assoc [
                ("word", `String word);
                ("isValid", `Bool is_valid)
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
