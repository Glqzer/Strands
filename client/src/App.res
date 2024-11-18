open React
open Promise
open Webapi

@react.component
let make = () => {
  let (board, setBoard) = useState(() => []) 
  let (selectedCells, setSelectedCells) = useState(() => list{}) 
  let (lastValidCell, setLastValidCell) = useState(() => None)

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

  useEffect1(() => {
    Js.Console.log2("Selected cells:", selectedCells)
    None
  }, [selectedCells])

  let isAdjacent = (prev, current) => {
    let (prevRow, prevCol) = prev;
    let (currentRow, currentCol) = current;
    let rowDiff = abs(prevRow - currentRow);
    let colDiff = abs(prevCol - currentCol);
    rowDiff <= 1 && colDiff <= 1;
  };

let handleCellClick = (rowIndex, colIndex) => {
  let coordinate = (rowIndex, colIndex);
  setSelectedCells(prev => {
    switch prev {
    | list{} => 
      list{coordinate}
    | list{head, ...rest} => 
        switch (lastValidCell) {
        | Some(lastValid) =>
          if isAdjacent(lastValid, coordinate) {
            if head == coordinate {
              rest
            } else {
              list{coordinate, ...prev}
            }
          } else {
            prev;
          }
        | None => 
            list{coordinate}
        };
      };
    });
    setLastValidCell(prev => 
      switch prev {
      | None => Some(coordinate)
      | Some(lastValid) =>
          if isAdjacent(lastValid, coordinate) {
            Some(coordinate)
          } else {
            prev
          }
      }
    );
  };

  let clearSelection = () => {
    setSelectedCells(_ => list{})
  }

  let isCellSelected = (rowIndex, colIndex) => {

    let coordinate = (rowIndex, colIndex)
    selectedCells->Belt.List.has(coordinate, (a, b) => a == b)
  }

  <div className="p-4">
    <h1 className="text-2xl font-bold mb-4">{React.string("Strands FP")}</h1>
    
    <div className="mb-4">
      <button 
        onClick={_ => clearSelection()}
        className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
      >
        {React.string("Clear Selection")}
      </button>
    </div>

    <div className="flex justify-center">
      <div className="grid grid-cols-6 gap-1">
        {board
        ->Belt.Array.mapWithIndex((rowIndex, row) => {
          row->Belt.Array.mapWithIndex((colIndex, letter) => {
            <Cell
              key={`cell-${rowIndex->Belt.Int.toString}-${colIndex->Belt.Int.toString}`}
              letter={letter}
              isSelected={isCellSelected(rowIndex, colIndex)}
              onClick={() => handleCellClick(rowIndex, colIndex)}
            />
          })->React.array
        })
        ->React.array}
      </div>
    </div>
  </div>
}