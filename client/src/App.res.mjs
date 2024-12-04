// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Cell from "./Cell.res.mjs";
import * as React from "react";
import * as Js_dict from "rescript/lib/es6/js_dict.js";
import * as Js_json from "rescript/lib/es6/js_json.js";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as PervasivesU from "rescript/lib/es6/pervasivesU.js";
import * as Core__Promise from "@rescript/core/src/Core__Promise.res.mjs";
import * as Webapi__Fetch from "rescript-webapi/src/Webapi/Webapi__Fetch.res.mjs";
import * as JsxRuntime from "react/jsx-runtime";

function App(props) {
  var match = React.useState(function () {
        return [];
      });
  var setBoard = match[1];
  var board = match[0];
  var match$1 = React.useState(function () {
        return /* [] */0;
      });
  var setSelectedCells = match$1[1];
  var selectedCells = match$1[0];
  var match$2 = React.useState(function () {
        
      });
  var setLastValidCell = match$2[1];
  var lastValidCell = match$2[0];
  var match$3 = React.useState(function () {
        return /* [] */0;
      });
  var setFoundWords = match$3[1];
  var match$4 = React.useState(function () {
        return "";
      });
  var setCurrentWord = match$4[1];
  var currentWord = match$4[0];
  React.useEffect((function () {
          Core__Promise.$$catch(fetch("http://localhost:8080/initialize").then(function (prim) {
                      return prim.json();
                    }).then(function (json) {
                    var obj = Js_json.decodeObject(json);
                    if (obj !== undefined) {
                      var boardJson = Js_dict.get(obj, "board");
                      if (boardJson !== undefined) {
                        var rows = Js_json.decodeArray(boardJson);
                        if (rows !== undefined) {
                          var board = Belt_Array.map(rows, (function (row) {
                                  var cells = Js_json.decodeArray(row);
                                  if (cells !== undefined) {
                                    return Belt_Array.map(cells, (function (cell) {
                                                  var letter = Js_json.decodeString(cell);
                                                  if (letter !== undefined) {
                                                    return letter;
                                                  } else {
                                                    return "";
                                                  }
                                                }));
                                  } else {
                                    return [];
                                  }
                                }));
                          setBoard(function (param) {
                                return board;
                              });
                        } else {
                          console.error("Invalid board array");
                        }
                      } else {
                        console.error("Could not find 'board' field");
                      }
                    } else {
                      console.error("Invalid JSON object");
                    }
                    return Promise.resolve();
                  }), (function (err) {
                  console.error("Error", err);
                  return Promise.resolve();
                }));
        }), []);
  var isAdjacent = function (prev, current) {
    var rowDiff = PervasivesU.abs(prev[0] - current[0] | 0);
    var colDiff = PervasivesU.abs(prev[1] - current[1] | 0);
    if (rowDiff <= 1) {
      return colDiff <= 1;
    } else {
      return false;
    }
  };
  var clearSelection = function () {
    setSelectedCells(function (param) {
          return /* [] */0;
        });
    setLastValidCell(function (param) {
          
        });
  };
  var isCellSelected = function (rowIndex, colIndex) {
    var coordinate = [
      rowIndex,
      colIndex
    ];
    return Belt_List.has(selectedCells, coordinate, Caml_obj.equal);
  };
  var handleSubmit = function () {
    var coordinates = Belt_List.map(Belt_List.reverse(selectedCells), (function (param) {
            return Js_dict.fromArray([
                        [
                          "row",
                          param[0]
                        ],
                        [
                          "col",
                          param[1]
                        ]
                      ]);
          }));
    Core__Promise.$$catch(fetch("http://localhost:8080/validate", Webapi__Fetch.RequestInit.make("Post", {
                      "Content-Type": "application/json",
                      "Access-Control-Allow-Methods": "POST",
                      "Access-Control-Allow-Origin": "http://127.0.0.1:5173"
                    }, Caml_option.some(Belt_Option.getWithDefault(JSON.stringify({
                                  word: currentWord,
                                  coordinates: coordinates
                                }), "{}")), undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined)).then(function (prim) {
                return prim.json();
              }).then(function (json) {
              var obj = Js_json.decodeObject(json);
              if (obj !== undefined) {
                var isValidJson = Js_dict.get(obj, "isValid");
                if (isValidJson !== undefined) {
                  var isValid = Js_json.decodeBoolean(isValidJson);
                  if (isValid !== undefined) {
                    if (isValid) {
                      setFoundWords(function (prev) {
                            return {
                                    hd: currentWord,
                                    tl: prev
                                  };
                          });
                      clearSelection();
                      console.log("Valid word!");
                    } else {
                      console.log("Invalid word!");
                    }
                  } else {
                    console.error("Invalid isValid value");
                  }
                } else {
                  console.error("No isValid field");
                }
              } else {
                console.error("Invalid JSON");
              }
              return Promise.resolve();
            }), (function (err) {
            console.error("Error validating word", err);
            return Promise.resolve();
          }));
  };
  var clearSelection$1 = function () {
    setSelectedCells(function (param) {
          return /* [] */0;
        });
    setLastValidCell(function (param) {
          
        });
    setCurrentWord(function (param) {
          return "";
        });
  };
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsx("h1", {
                      children: "Strands FP",
                      className: "text-2xl font-bold mb-4"
                    }),
                JsxRuntime.jsx("p", {
                      children: currentWord,
                      className: "text-center h-[30px]"
                    }),
                JsxRuntime.jsx("div", {
                      children: JsxRuntime.jsx("div", {
                            children: Belt_Array.mapWithIndex(board, (function (rowIndex, row) {
                                    return Belt_Array.mapWithIndex(row, (function (colIndex, letter) {
                                                  return JsxRuntime.jsx(Cell.make, {
                                                              letter: letter,
                                                              isSelected: isCellSelected(rowIndex, colIndex),
                                                              onClick: (function () {
                                                                  var coordinate = [
                                                                    rowIndex,
                                                                    colIndex
                                                                  ];
                                                                  var row = Belt_Array.get(board, rowIndex);
                                                                  var letter;
                                                                  if (row !== undefined) {
                                                                    var l = Belt_Array.get(row, colIndex);
                                                                    letter = l !== undefined ? l : "";
                                                                  } else {
                                                                    letter = "";
                                                                  }
                                                                  setSelectedCells(function (prev) {
                                                                        if (prev && lastValidCell !== undefined) {
                                                                          if (isAdjacent(lastValidCell, coordinate)) {
                                                                            if (Caml_obj.equal(prev.hd, coordinate)) {
                                                                              return prev.tl;
                                                                            } else {
                                                                              return {
                                                                                      hd: coordinate,
                                                                                      tl: prev
                                                                                    };
                                                                            }
                                                                          } else {
                                                                            return prev;
                                                                          }
                                                                        } else {
                                                                          return {
                                                                                  hd: coordinate,
                                                                                  tl: /* [] */0
                                                                                };
                                                                        }
                                                                      });
                                                                  setCurrentWord(function (prev) {
                                                                        return prev + letter;
                                                                      });
                                                                  setLastValidCell(function (prev) {
                                                                        if (prev !== undefined && !isAdjacent(prev, coordinate)) {
                                                                          return prev;
                                                                        } else {
                                                                          return coordinate;
                                                                        }
                                                                      });
                                                                })
                                                            }, "cell-" + String(rowIndex) + "-" + String(colIndex));
                                                }));
                                  })),
                            className: "grid grid-cols-6 gap-1"
                          }),
                      className: "flex justify-center"
                    }),
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsx("button", {
                              children: "Submit",
                              className: "px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600",
                              onClick: (function (param) {
                                  handleSubmit();
                                })
                            }),
                        JsxRuntime.jsx("button", {
                              children: "Clear",
                              className: "px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600",
                              onClick: (function (param) {
                                  clearSelection$1();
                                })
                            })
                      ],
                      className: "mt-4 flex gap-2 justify-center"
                    }),
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsx("h2", {
                              children: "Found words:",
                              className: "text-xl font-semibold"
                            }),
                        JsxRuntime.jsx("ul", {
                              children: Belt_Array.map(Belt_List.toArray(match$3[0]), (function (word) {
                                      return JsxRuntime.jsx("li", {
                                                  children: word
                                                }, word);
                                    }))
                            })
                      ],
                      className: "mt-4"
                    })
              ],
              className: "p-4"
            });
}

var make = App;

export {
  make ,
}
/* Cell Not a pure module */
