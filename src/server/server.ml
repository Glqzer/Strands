let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [
    Dream.get "/"
      (fun _ ->
        let json = `Assoc [("message", `String "Good morning, world")] in
        Dream.json (Yojson.Safe.to_string json));

    Dream.get "/echo/:word" @@ fun request ->
      let word = Dream.param request "word" in
      let json = `Assoc [("echo", `String word)] in
      Dream.json (Yojson.Safe.to_string json);
  ]