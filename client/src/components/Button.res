@react.component
let make = (~type_: string, ~children: React.element) => {
let buttonClassName = switch type_ {
  | "submit" => "bg-blue-600 hover:bg-blue-700 focus:bg-blue-700"
  | "clear" => "bg-red-600 hover:bg-red-700 focus:bg-red-700"
  | "static" => "bg-cyan-600 hover:bg-cyan-700 focus:bg-cyan-700"
  | "dynamic" => "bg-emerald-600 hover:bg-emerald-700 focus:bg-emerald-700" 
  | _ => "bg-gray-600 hover:bg-gray-700 focus:bg-gray-700"
}

<button
  className={"inline-block px-6 py-2.5 text-white font-medium text-xs leading-tight uppercase rounded shadow-md focus:outline-none focus:ring-0 transition duration-150 ease-in-out " ++ buttonClassName}
>
  children
</button>
}
