open Utils
open Words

(*temp solution grid*)
let solution_coords = 
  let open WordCoords in
  empty
  |> add "apple" [(6,0);(7,0);(7,1);(7,2);(6,2)]

(* let solution_status =
  let open WordRecord in
  empty
  |> add "apple" 0 *)

let () =
  Dream.run
  @@ Dream.logger
  
  @@ Dream.router [
    Dream.get "/"
      (fun _ ->
        let response = 
          `Assoc [("message", `String "Good morning, world")]
          |> Yojson.Safe.to_string
        in
        Dream.respond ~headers:[("Content-Type", "application/json"); ("Access-Control-Allow-Origin", "http://127.0.0.1:5173"
        )] response);

      Dream.get "/initialize" 
        (fun _ ->
          let board = sample_grid in
          let response = `Assoc [("board", `List (
            List.map (fun row ->
              `List (List.map (fun c -> `String (String.make 1 c)) row)
            ) board
          ))]
          |> Yojson.Safe.to_string
        in 
        Dream.respond ~headers:[("Content-Type", "application/json"); ("Access-Control-Allow-Origin", "http://127.0.0.1:5173")] response);

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
            Dream.respond ~headers:[("Content-Type", "application/json"); ("Access-Control-Allow-Origin", "http://127.0.0.1:5173")] response;
          with 
          | _ -> 
            Dream.respond 
              ~status:`Bad_Request 
              ~headers:[("Content-Type", "application/json"); ("Access-Control-Allow-Origin", "http://127.0.0.1:5173")] 
              {|{"error": "Invalid request"}|}
        )
      )
  ]