@react.component
let make = (~letter: string, ~isSelected: bool, ~onClick: unit => unit) => {
  <div 
    className={`w-12 h-12 border border-gray-300 flex items-center justify-center font-bold cursor-pointer rounded-md ${isSelected ? "bg-gray-200" : ""}`}
    onClick={_ => onClick()}
  >
    {React.string(letter)}
  </div>
}