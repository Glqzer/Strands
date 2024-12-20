// Generated by ReScript, PLEASE EDIT WITH CARE

import * as JsxRuntime from "react/jsx-runtime";

function Cell(props) {
  var onClick = props.onClick;
  var __isSpangram = props.isSpangram;
  var isFound = props.isFound;
  var isSpangram = __isSpangram !== undefined ? __isSpangram : false;
  return JsxRuntime.jsx("div", {
              children: props.letter,
              className: "w-12 h-12 border border-gray-300 flex items-center justify-center font-bold rounded-md \r\n      " + (
                isFound ? (
                    isSpangram ? "bg-amber-300 cursor-default" : "bg-emerald-300 cursor-default"
                  ) : "cursor-pointer"
              ) + " \r\n      " + (
                props.isSelected ? "bg-gray-200" : ""
              ),
              onClick: (function (param) {
                  if (!isFound) {
                    return onClick();
                  }
                  
                })
            });
}

var make = Cell;

export {
  make ,
}
/* react/jsx-runtime Not a pure module */
