@react.component
let make = (~letter: string, ~isSelected: bool, ~isFound: bool, ~isSpangram: bool=false, ~onClick: unit => unit) => {
  <div 
    className={`w-12 h-12 border border-gray-300 flex items-center justify-center font-bold rounded-md 
      ${isFound 
        ? (isSpangram ? "bg-amber-300 cursor-default" : "bg-emerald-300 cursor-default") 
        : "cursor-pointer"} 
      ${isSelected ? "bg-gray-200" : ""}`}
    onClick={_ => if (!isFound) { onClick(); }}
  >
    {React.string(letter)}
  </div>
};