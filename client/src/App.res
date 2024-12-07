open React
open Promise
open Webapi

@react.component
let make = () => {
  let (board, setBoard) = useState(() => []) 
  let (selectedCells, setSelectedCells) = useState(() => list{}) 
  let (lastValidCell, setLastValidCell) = useState(() => None)
  let (foundWords, setFoundWords) = useState(() => list{})
  let (currentWord, setCurrentWord) = useState(() => "")
  let (foundCells, setFoundCells) = useState(() => list{});



  useEffect0(() => {
    // initialize the grid by fetching the initial game board
    // TO-DO replace this with fetching the game state instead
    let _ = Fetch.fetch("http://localhost:8080/initialize")
    ->then(Fetch.Response.json)
    ->then(json => {
      switch Js.Json.decodeObject(json) {
      | Some(obj) =>
        switch obj->Js.Dict.get("board") {
        | Some(boardJson) =>
          switch Js.Json.decodeArray(boardJson) {
          | Some(rows) =>
            let board = rows->Array.map(row =>
              switch Js.Json.decodeArray(row) {
              | Some(cells) =>
                cells->Array.map(cell =>
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

  let isAdjacent = (prev, current) => {
    let (prevRow, prevCol) = prev;
    let (currentRow, currentCol) = current;
    let rowDiff = abs(prevRow - currentRow);
    let colDiff = abs(prevCol - currentCol);
    rowDiff <= 1 && colDiff <= 1;
  };

  // handles cell selection
  let handleCellClick = (rowIndex, colIndex) => {
    let coordinate = (rowIndex, colIndex);
    // get the letter of the cell
    let letter = 
      switch (board->Belt.Array.get(rowIndex)) {
      | Some(row) => 
          switch (row->Belt.Array.get(colIndex)) {
          | Some(l) => l
          | None => ""
          }
      | None => ""
      };
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
    switch (lastValidCell) {
    | Some(lastValid) =>
      if isAdjacent(lastValid, coordinate) {
        setCurrentWord(prev => 
          switch (selectedCells->Belt.List.has(coordinate, (a, b) => a == b)) {
          | true => 
              Js.String.slice(prev, ~from=0, ~to_=Js.String.length(prev) - 1)
          | false =>
              prev ++ letter
          }
        );
      }
    | None =>
      setCurrentWord(prev => prev ++ letter);
    }
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

  // clears the selected word
  let clearWord = () => {
    setSelectedCells(_ => list{})
    setLastValidCell(_ => None)
    setCurrentWord(_ => "")
  }
  
  // updates the coordinates of selected cells
  let isCellSelected = (rowIndex, colIndex) => {
    let coordinate = (rowIndex, colIndex)
    selectedCells->Belt.List.has(coordinate, (a, b) => a == b)
  }

  // updates the coordinates of found cells
  let isCellFound = (rowIndex, colIndex) => {
    let coordinate = (rowIndex, colIndex);
    foundCells->Belt.List.has(coordinate, (a, b) => a == b);
  };

  // handles submitting a word for validation
  let handleSubmit = () => {
    let coordinates = 
      selectedCells
      ->Belt.List.reverse
      ->Belt.List.map(((row, col)) => {
        {
          "row": float_of_int(row),
          "col": float_of_int(col)
        }
      })
      ->Belt.List.toArray;

    // make a post request to the server to validate the word
    let _ = 
      Fetch.fetchWithInit("http://localhost:8080/validate", 
        Fetch.RequestInit.make(
          ~method_=Post, 
          ~body=Fetch.BodyInit.make(
            Js.Json.stringifyAny({
              "word": currentWord,
              "coordinates": coordinates
            })->Belt.Option.getWithDefault("{}")
          ), 
          ~headers=Fetch.HeadersInit.make({
            "Content-Type": "application/json",
            "Access-Control-Allow-Methods":"POST",
            "Access-Control-Allow-Origin": "http://127.0.0.1:5173"
          }),
          ()
        )
      )
      ->then(Fetch.Response.json)
      ->then(json => {
        switch Js.Json.decodeObject(json) {
        | Some(obj) => 
          switch obj->Js.Dict.get("isValid") {
          | Some(isValidJson) => 
            switch Js.Json.decodeBoolean(isValidJson) {
            | Some(isValid) => 
              if (isValid) {
                setFoundWords(prev => list{currentWord, ...prev});
                setFoundCells(prev => list{...prev, ...selectedCells});
                clearWord();
                Js.Console.log("Valid word!");
              } else {
                Js.Console.log("Invalid word!");
              }
            | None => Js.Console.error("Invalid isValid value")
            }
          | None => Js.Console.error("No isValid field")
          }
        | None => Js.Console.error("Invalid JSON")
        }
        resolve()
      })
      ->catch(err => {
        Js.Console.error2("Error validating word", err)
        resolve()
      });
  };
  


  <div className="p-4">
    <h1 className="text-2xl font-bold mb-4">{React.string("FP Strands")}</h1>
    <p className="text-center h-[30px]">{string(currentWord)}</p>
    <div className="flex justify-center">
      <div className="grid grid-cols-6 gap-1">
        {board
        ->Belt.Array.mapWithIndex((rowIndex, row) => {
          row->Belt.Array.mapWithIndex((colIndex, letter) => {
            <Cell
              key={`cell-${rowIndex->Belt.Int.toString}-${colIndex->Belt.Int.toString}`}
              letter={letter}
              isSelected={isCellSelected(rowIndex, colIndex)}
              isFound={isCellFound(rowIndex, colIndex)}
              onClick={() => handleCellClick(rowIndex, colIndex)}
            />
          })->React.array
        })
        ->React.array}
      </div>
    </div>
    <div className="mt-4 flex gap-2 justify-center">
      <button 
        className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
        onClick={_ => handleSubmit()}
      >
        {React.string("Submit")}
      </button>
      <button 
        className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600"
        onClick={_ => clearWord()}
      >
        {React.string("Clear")}
      </button>
    </div>
    <div className="mt-4">
      <h2 className="text-xl font-semibold">{React.string("Found words:")}</h2>
      <ul>
        {foundWords
        ->Belt.List.toArray
        ->Belt.Array.map(word => 
          <li key={word}>{React.string(word)}</li>
        )
        ->React.array}
      </ul>
    </div>
  </div>
}
