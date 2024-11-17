@react.component
let make = (~letter: string) => {
  <div className="w-12 h-12 border border-gray-300 flex items-center justify-center font-bold cursor-pointer">
    {React.string(letter)}
  </div>
}