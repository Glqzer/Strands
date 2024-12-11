// Generated by ReScript, PLEASE EDIT WITH CARE

import * as JsxRuntime from "react/jsx-runtime";

function Button(props) {
  var onClick = props.onClick;
  var buttonClassName;
  switch (props.type_) {
    case "clear" :
        buttonClassName = "bg-rose-600 hover:bg-rose-700";
        break;
    case "dynamic" :
        buttonClassName = "bg-emerald-600 hover:bg-emerald-700";
        break;
    case "github" :
        buttonClassName = "bg-slate-800 hover:bg-slate-900";
        break;
    case "slides" :
        buttonClassName = "bg-amber-500 hover:bg-amber-600";
        break;
    case "static" :
        buttonClassName = "bg-cyan-600 hover:bg-cyan-700";
        break;
    case "submit" :
        buttonClassName = "bg-sky-600 hover:bg-sky-700";
        break;
    default:
      buttonClassName = "bg-gray-600 hover:bg-gray-700";
  }
  var handleClick = onClick !== undefined ? onClick : (function (param) {
        
      });
  return JsxRuntime.jsx("button", {
              children: props.children,
              className: "inline-block px-6 py-3 text-white font-medium text-xs leading-tight rounded shadow-md transition duration-150 ease-in-out " + buttonClassName,
              onClick: handleClick
            });
}

var make = Button;

export {
  make ,
}
/* react/jsx-runtime Not a pure module */
