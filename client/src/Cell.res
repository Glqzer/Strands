@react.component
let make = (~letter: string, ~isSelected: bool, ~isFound: bool, ~onClick: unit => unit) => {
  <div 
    className={`w-12 h-12 border border-gray-300 flex items-center justify-center font-bold rounded-md 
      ${isFound ? "bg-green-300 cursor-default" : "cursor-pointer"} ${isSelected ? "bg-gray-200" : ""}`}
    onClick={_ => if (!isFound) { onClick(); }}
  >
    {React.string(letter)}
  </div>
};
