@react.component
let make = (
  ~board: array<array<string>>, 
  ~selectedCells: list<(int, int)>, 
  ~foundCells: list<(int, int)>, 
  ~spangramCells: list<(int, int)>, 
  ~onCellClick: (int, int) => unit
) => {
  let isCellSelected = (rowIndex, colIndex) => {
    let coordinate = (rowIndex, colIndex)
    selectedCells->Belt.List.has(coordinate, (a, b) => a == b)
  }

  let isCellFound = (rowIndex, colIndex) => {
    let coordinate = (rowIndex, colIndex);
    foundCells->Belt.List.has(coordinate, (a, b) => a == b);
  };

  let isCellSpangram = (rowIndex, colIndex) => {
    let coordinate = (rowIndex, colIndex);
    spangramCells->Belt.List.has(coordinate, (a, b) => a == b);
  };

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
            isSpangram={isCellSpangram(rowIndex, colIndex)}
            onClick={() => onCellClick(rowIndex, colIndex)}
          />
        })->React.array
      })
      ->React.array}
    </div>
  </div>
}