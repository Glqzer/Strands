@react.component
let make = (
  ~foundWords: list<(string)>, 
) => {
    <div>
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
}