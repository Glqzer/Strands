open React
open Promise
open Webapi

@react.component
let make = (~mode: [#static | #dynamic | #playground]) => {
  let (board, setBoard) = useState(() => []) 
  let (theme, setTheme) = useState(() => "")
  let (selectedCells, setSelectedCells) = useState(() => list{}) 
  let (lastValidCell, setLastValidCell) = useState(() => None)
  let (foundWords, setFoundWords) = useState(() => list{})
  let (currentWord, setCurrentWord) = useState(() => "")
  let (foundCells, setFoundCells) = useState(() => list{})
  let (spangramCells, setSpangramCells) = useState(() => list{})
  
  // playground mode states
  let (playgroundTheme, setPlaygroundTheme) = useState(() => "")
  let (playgroundSpangram, setPlaygroundSpangram) = useState(() => "")
  let (isPlaygroundInitialized, setIsPlaygroundInitialized) = useState(() => false)

  let gameInitialization = json => {
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

  let themeResult = 
    json
    ->Js.Json.decodeObject
    ->Belt.Option.flatMap(obj => obj->Js.Dict.get("theme"))
    ->Belt.Option.flatMap(Js.Json.decodeString);
  
  switch boardResult {
  | Some(initialBoard) => setBoard(_ => initialBoard)
  | None => Js.Console.error("Failed to initialize board")
  };

  switch themeResult {
  | Some(initialTheme) => setTheme(_ => initialTheme)
  | None => Js.Console.error("Failed to retrieve theme")
  };

  resolve()
};

  useEffect0(() => {
    let modeString = switch mode {
    | #static => "static"
    | #dynamic => "dynamic"
    | #playground => "playground"
    };

    let _ = Fetch.fetch(`http://localhost:8080/initialize?mode=${modeString}`)
      ->then(Fetch.Response.json)
      ->then(gameInitialization)
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
        | Some(lastValid) when lastValid == coordinate =>
          rest
        | Some(lastValid) when isAdjacent(lastValid, coordinate) && !(selectedCells->Belt.List.has(coordinate, (a, b) => a == b)) =>
          head == coordinate ? rest : list{coordinate, ...prev}
        | _ => prev
        }
      }
    });

    switch lastValidCell {
    | Some(lastValid) when lastValid == coordinate =>
      setCurrentWord(prev => 
        selectedCells->Belt.List.has(coordinate, (a, b) => a == b)
          ? Js.String.slice(prev, ~from=0, ~to_=Js.String.length(prev) - 1)
          : prev ++ letter
      )
    | Some(lastValid) when isAdjacent(lastValid, coordinate) && !(selectedCells->Belt.List.has(coordinate, (a, b) => a == b)) =>
      setCurrentWord(prev => prev ++ letter)
    | Some(lastValid) =>
      setCurrentWord(prev => prev)
    | _ => 
      setCurrentWord(prev => prev ++ letter)
    };

    let secondToLast = selectedCells
      ->Belt.List.get(1);

    setLastValidCell(prev => 
      switch prev {
      | None => Some(coordinate)
      | Some(lastValid) when lastValid == coordinate =>
        switch secondToLast {
        | None => None
        | Some(validCell) => Some(validCell)
        }
      | Some(lastValid) when isAdjacent(lastValid, coordinate) && !(selectedCells->Belt.List.has(coordinate, (a, b) => a == b)) => 
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

    let modeString = switch mode {
    | #static => "static"
    | #dynamic => "dynamic"
    | #playground => "playground"
    };

    let _ = 
      Fetch.fetchWithInit(`http://localhost:8080/validate?mode=${modeString}`, 
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

  // playground initialization
  let handlePlaygroundInitialize = () => {

    let playgroundData = {
      "theme": playgroundTheme,
      "spangram": playgroundSpangram
    };

    let _ = 
      Fetch.fetchWithInit(`http://localhost:8080/initialize-playground`, 
        Fetch.RequestInit.make(
          ~method_=Post, 
          ~body=Fetch.BodyInit.make(
            Js.Json.stringifyAny(playgroundData)->Belt.Option.getWithDefault("{}")
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
      ->then(gameInitialization)
      ->then(_ => {
        setIsPlaygroundInitialized(_ => true)
        resolve()
      })
      ->catch(err => {
        Js.Console.error2("Error initializing playground", err)
        resolve()
      });
  };

  let pageTitle = switch mode {
  | #static => "FP Strands - Static"
  | #dynamic => "FP Strands - Dynamic"
  | #playground => "FP Strands - Playground"
  };

  let handleThemeChange = event => {
    let value = ReactEvent.Form.currentTarget(event)["value"]
    setPlaygroundTheme(_ => value)
  }

  let handleSpangramChange = event => {
    let value = ReactEvent.Form.currentTarget(event)["value"]
    setPlaygroundSpangram(_ => value)
  }

  let themeText = mode == #playground && !isPlaygroundInitialized 
    ? playgroundTheme 
    : theme;

  <div className="content">
    <h1 className="text-2xl font-bold mb-4">{React.string(pageTitle)}</h1>
    
    {switch mode {
    | #playground => 
      <div className="playground-setup flex justify-center gap-4 mb-4">
        <div>
          <label className="block mb-2">{React.string("Theme")}</label>
          <input 
            type_="text"
            placeholder="Enter Theme"
            value={playgroundTheme}
            onChange={handleThemeChange}
            className="border p-2 w-full"
          />
        </div>
        <div>
          <label className="block mb-2">{React.string("Spangram")}</label>
          <input 
            type_="text"
            placeholder="Enter Spangram"
            value={playgroundSpangram}
            onChange={handleSpangramChange}
            className="border p-2 w-full"
          />
        </div>
        <div className="flex items-end">
          <Button 
            type_="submit"
            onClick={_ => handlePlaygroundInitialize()}
          >
            {React.string("Initialize Game")}
          </Button>
        </div>
      </div>
    | #static 
    | #dynamic => React.null
    }}

    <p className="text-center h-[30px]">{React.string(currentWord)}</p>

    <div className="game-content">
      {switch mode {
      | #playground when !isPlaygroundInitialized => React.null
      | #playground 
      | #static 
      | #dynamic => 
        <> 
          <div className="side-panel content-center">
            <Theme theme={themeText}/>
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
              <Button 
                type_="clear"
                onClick={_ => clearWord()}
              >
                {React.string("Clear")}
              </Button>
              <Button 
                type_="submit"
                onClick={_ => handleSubmit()}
              >
                {React.string("Submit")}
              </Button>
            </div>
          </div>
          <div className="side-panel">
            <Words foundWords={foundWords} />
          </div>
        </>
      }}
    </div>
  </div>
}