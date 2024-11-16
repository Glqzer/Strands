open Webapi
open Promise



@react.component
let make = () => {
  let (echo, setEcho) = React.useState(() => "")

  React.useEffect0(() => {
    let _ = Fetch.fetch("http://localhost:8080/echo/hi")
    ->then(Fetch.Response.json)
    ->then(json => {
        switch Js.Json.decodeObject(json) {
        | Some(obj) =>
          switch obj->Js.Dict.get("echo") {
          | Some(value) =>
            switch Js.Json.decodeString(value) {
            | Some(echoText) => setEcho(_ => echoText)
            | None => Js.Console.error("Value is not a string")
            }
          | None => Js.Console.error("Could not find 'echo' field")
          }
        | None => Js.Console.error("Invalid JSON object")
        }
        resolve()
    })
    ->catch(err => {
      Js.Console.error2("Error fetching data:", err)
      resolve()
    })
    
    None
  })

  <div>
    <p> {React.string("Echo response: " ++ echo)} </p>
  </div>
}
