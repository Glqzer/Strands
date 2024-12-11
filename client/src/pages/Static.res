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
  let (foundCells, setFoundCells) = useState(() => list{})
  let (spangramCells, setSpangramCells) = useState(() => list{})

  useEffect0(() => {
    let handleBoardInitialization = json => {
      let boardResult = 
        json
        ->Js.Json.decodeObject
        ->Belt.Option.flatMap(obj => obj->Js.Dict.get("board"))
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(rows => 
          rows->Array.map(row => 
            switch Js.Json.decodeArray(row) {
            | Some(cells) => 
              cells->Array.map(cell => 
                cell->Js.Json.decodeString->Belt.Option.getWithDefault("")
              )
            | None => []
            }
          )
        );

      switch boardResult {
      | Some(initialBoard) => setBoard(_ => initialBoard)
      | None => Js.Console.error("Failed to initialize board")
      };
      resolve()
    };

    let _ = Fetch.fetch("http://localhost:8080/initialize?mode=static")
      ->then(Fetch.Response.json)
      ->then(handleBoardInitialization)
      ->catch(err => {
        Js.Console.error2("Error", err)
        resolve()
      });

    None
  });

  let isAdjacent = ((prevRow, prevCol), (currentRow, currentCol)) => {
    let rowDiff = abs(prevRow - currentRow);
    let colDiff = abs(prevCol - currentCol);
    rowDiff <= 1 && colDiff <= 1;
  };

  let getArrayValue = (arr, index, defaultValue) => 
    arr->Belt.Array.get(index)->Belt.Option.getWithDefault(defaultValue)

  let getLetterAt = (rowIndex, colIndex) => 
    board
    ->getArrayValue(rowIndex, [])
    ->getArrayValue(colIndex, "");

  let handleCellClick = (rowIndex, colIndex) => {
    let coordinate = (rowIndex, colIndex);
    let letter = getLetterAt(rowIndex, colIndex);

    setSelectedCells(prev => {
      switch prev {
      | list{} => list{coordinate}
      | list{head, ...rest} => 
        switch lastValidCell {
        | Some(lastValid) when isAdjacent(lastValid, coordinate) =>
          head == coordinate ? rest : list{coordinate, ...prev}
        | _ => prev
        }
      }
    });

    switch lastValidCell {
    | Some(lastValid) when isAdjacent(lastValid, coordinate) =>
      setCurrentWord(prev => 
        selectedCells->Belt.List.has(coordinate, (a, b) => a == b)
          ? Js.String.slice(prev, ~from=0, ~to_=Js.String.length(prev) - 1)
          : prev ++ letter
      )
    | _ => 
      setCurrentWord(prev => prev ++ letter)
    };

    setLastValidCell(prev => 
      switch prev {
      | None => Some(coordinate)
      | Some(lastValid) when isAdjacent(lastValid, coordinate) => 
        Some(coordinate)
      | _ => prev
      }
    );
  };

  let clearWord = () => {
    setSelectedCells(_ => list{})
    setLastValidCell(_ => None)
    setCurrentWord(_ => "")
  }


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

    let handleValidationResponse = json => {
      let validationResult = 
        json
        ->Js.Json.decodeObject
        ->Belt.Option.flatMap(obj => 
          obj->Js.Dict.get("isValid")
          ->Belt.Option.flatMap(Js.Json.decodeBoolean)
        );

      switch validationResult {
      | Some(true) => 
        let isSpangram = 
          json
          ->Js.Json.decodeObject
          ->Belt.Option.flatMap(obj => 
            obj->Js.Dict.get("isSpangram")
            ->Belt.Option.flatMap(Js.Json.decodeBoolean)
          );

        switch isSpangram {
        | Some(true) => 
          Js.Console.log("Spangram word!");
          setFoundWords(prev => list{currentWord, ...prev});
          setFoundCells(prev => list{...prev, ...selectedCells});
          setSpangramCells(prev => list{...prev, ...selectedCells});
          clearWord();
        | _ => 
          Js.Console.log("Valid word!");
          setFoundWords(prev => list{currentWord, ...prev});
          setFoundCells(prev => list{...prev, ...selectedCells});
          clearWord();
        };

      | Some(false) => 
        Js.Console.log("Invalid word!")
      | None => 
        Js.Console.error("Invalid validation response")
      };

      resolve()
    };

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
      ->then(handleValidationResponse)
      ->catch(err => {
        Js.Console.error2("Error validating word", err)
        resolve()
      });
  };

  <div className="content">
    <h1 className="text-2xl font-bold mb-4">{React.string("FP Strands - Static")}</h1>
    <p className="text-center h-[30px]">{string(currentWord)}</p>
    <div className="game-content">
      <div className="side-panel">
        <Theme theme="Let's strand"/>
      </div>
      <div className="grid-w-controls">
        <Grid 
          board={board}
          selectedCells={selectedCells}
          foundCells={foundCells}
          spangramCells={spangramCells}
          onCellClick={handleCellClick}
        />

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
      </div>
      <div className="side-panel">
        <Words foundWords={foundWords} />
      </div>
    </div>
  </div>
}