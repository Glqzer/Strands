// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as JsxRuntime from "react/jsx-runtime";

function Words(props) {
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsx("h2", {
                      children: "Found words:",
                      className: "text-xl font-semibold"
                    }),
                JsxRuntime.jsx("ul", {
                      children: Belt_Array.map(Belt_List.toArray(props.foundWords), (function (word) {
                              return JsxRuntime.jsx("li", {
                                          children: word
                                        }, word);
                            }))
                    })
              ]
            });
}

var make = Words;

export {
  make ,
}
/* react/jsx-runtime Not a pure module */
