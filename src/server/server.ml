let () =
  Dream.run ~interface:"0.0.0.0" ~port:8080
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

    Dream.get "/echo/:word" @@ fun request ->
      let word = Dream.param request "word" in
      let response = 
        `Assoc [("echo", `String word)]
        |> Yojson.Safe.to_string
      in
      Dream.respond ~headers:[("Content-Type", "application/json"); ("Access-Control-Allow-Origin", "http://127.0.0.1:5173")] response;
  ]