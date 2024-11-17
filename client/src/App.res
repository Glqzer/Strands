// App.res
open Webapi
open Promise
open React

type boardState = array<array<string>>

@react.component
let make = () => {
  let (board, setBoard) = useState(() => [])

  useEffect0(() => {
    let _ = Fetch.fetch("http://localhost:8080/initialize")
    ->then(Fetch.Response.json)
    ->then(json => {
      switch Js.Json.decodeObject(json) {
      | Some(obj) =>
        switch obj->Js.Dict.get("board") {
        | Some(boardJson) =>
          switch Js.Json.decodeArray(boardJson) {
          | Some(rows) =>
            let board = rows->Belt.Array.map(row =>
              switch Js.Json.decodeArray(row) {
              | Some(cells) =>
                cells->Belt.Array.map(cell =>
                  switch Js.Json.decodeString(cell) {
                  | Some(letter) => letter
                  | None => ""
                  }
                )
              | None => []
              }
            )
            setBoard(_ => board)
          | None => Js.Console.error("Invalid board array")
          }
        | None => Js.Console.error("Could not find 'board' field")
        }
      | None => Js.Console.error("Invalid JSON object")
      }
      resolve()
    })
    ->catch(err => {
      Js.Console.error2("Error", err)
      resolve()
    })
    None
  })
<div>
    <h1 className="mb-3">{string("Strands FP")}</h1>
    <div className="flex justify-center">
      <div className="grid grid-cols-6 gap-1">
        {board
        ->Belt.Array.mapWithIndex((rowIndex, row) => {
          row->Belt.Array.mapWithIndex((colIndex, letter) => {
            <Cell
              key={`cell-${rowIndex->Js.Int.toString}-${colIndex->Belt.Int.toString}`}
              letter={letter}
            />
          })->array
        })
        ->array}
      </div>
    </div>
  </div>
}