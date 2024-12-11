@react.component
let make = (~type_: string, ~onClick: option<ReactEvent.Mouse.t => unit>=?, ~children: React.element) => {
  let buttonClassName = switch type_ {
    | "submit" => "bg-sky-600 hover:bg-sky-700"
    | "clear" => "bg-rose-600 hover:bg-rose-700"
    | "static" => "bg-cyan-600 hover:bg-cyan-700"
    | "dynamic" => "bg-emerald-600 hover:bg-emerald-700" 
    | "slides" => "bg-amber-500 hover:bg-amber-600" 
    | _ => "bg-gray-600 hover:bg-gray-700"
  }

  let handleClick = switch onClick {
    | Some(handler) => handler
    | None => _ => ()
  }

  <button
    className={
      "inline-block px-6 py-3 text-white font-medium text-xs leading-tight rounded shadow-md transition duration-150 ease-in-out " ++ buttonClassName
    }
    onClick={handleClick}
  >
    {children}
  </button>
}
