open Utils

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

    Dream.get "/echo/:word" 
      (fun request ->
        let word = Dream.param request "word" in
        let response = 
          `Assoc [("echo", `String word)]
          |> Yojson.Safe.to_string
        in
        Dream.respond ~headers:[("Content-Type", "application/json"); ("Access-Control-Allow-Origin", "http://127.0.0.1:5173")] response);

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
  ]