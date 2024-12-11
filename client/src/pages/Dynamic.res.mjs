// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Grid from "../components/Grid.res.mjs";
import * as Theme from "../components/Theme.res.mjs";
import * as Words from "../components/Words.res.mjs";
import * as React from "react";
import * as Js_dict from "rescript/lib/es6/js_dict.js";
import * as Js_json from "rescript/lib/es6/js_json.js";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as Js_string from "rescript/lib/es6/js_string.js";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as PervasivesU from "rescript/lib/es6/pervasivesU.js";
import * as Core__Promise from "@rescript/core/src/Core__Promise.res.mjs";
import * as Webapi__Fetch from "rescript-webapi/src/Webapi/Webapi__Fetch.res.mjs";
import * as JsxRuntime from "react/jsx-runtime";

function Dynamic(props) {
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
  var match$5 = React.useState(function () {
        return /* [] */0;
      });
  var setFoundCells = match$5[1];
  var match$6 = React.useState(function () {
        return /* [] */0;
      });
  var setSpangramCells = match$6[1];
  React.useEffect((function () {
          var handleBoardInitialization = function (json) {
            var boardResult = Belt_Option.map(Belt_Option.flatMap(Belt_Option.flatMap(Js_json.decodeObject(json), (function (obj) {
                            return Js_dict.get(obj, "board");
                          })), Js_json.decodeArray), (function (rows) {
                    return rows.map(function (row) {
                                var cells = Js_json.decodeArray(row);
                                if (cells !== undefined) {
                                  return cells.map(function (cell) {
                                              return Belt_Option.getWithDefault(Js_json.decodeString(cell), "");
                                            });
                                } else {
                                  return [];
                                }
                              });
                  }));
            if (boardResult !== undefined) {
              setBoard(function (param) {
                    return boardResult;
                  });
            } else {
              console.error("Failed to initialize board");
            }
            return Promise.resolve();
          };
          Core__Promise.$$catch(fetch("http://localhost:8080/initialize?mode=dynamic\n").then(function (prim) {
                      return prim.json();
                    }).then(handleBoardInitialization), (function (err) {
                  console.error("Error", err);
                  return Promise.resolve();
                }));
        }), []);
  var isAdjacent = function (param, param$1) {
    var rowDiff = PervasivesU.abs(param[0] - param$1[0] | 0);
    var colDiff = PervasivesU.abs(param[1] - param$1[1] | 0);
    if (rowDiff <= 1) {
      return colDiff <= 1;
    } else {
      return false;
    }
  };
  var getArrayValue = function (arr, index, defaultValue) {
    return Belt_Option.getWithDefault(Belt_Array.get(arr, index), defaultValue);
  };
  var getLetterAt = function (rowIndex, colIndex) {
    return getArrayValue(getArrayValue(board, rowIndex, []), colIndex, "");
  };
  var handleCellClick = function (rowIndex, colIndex) {
    var coordinate = [
      rowIndex,
      colIndex
    ];
    var letter = getLetterAt(rowIndex, colIndex);
    setSelectedCells(function (prev) {
          if (prev) {
            if (lastValidCell !== undefined && isAdjacent(lastValidCell, coordinate)) {
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
    var exit = 0;
    if (lastValidCell !== undefined && isAdjacent(lastValidCell, coordinate)) {
      setCurrentWord(function (prev) {
            if (Belt_List.has(selectedCells, coordinate, Caml_obj.equal)) {
              return Js_string.slice(0, prev.length - 1 | 0, prev);
            } else {
              return prev + letter;
            }
          });
    } else {
      exit = 1;
    }
    if (exit === 1) {
      setCurrentWord(function (prev) {
            return prev + letter;
          });
    }
    setLastValidCell(function (prev) {
          if (prev !== undefined && !isAdjacent(prev, coordinate)) {
            return prev;
          } else {
            return coordinate;
          }
        });
  };
  var clearWord = function () {
    setSelectedCells(function (param) {
          return /* [] */0;
        });
    setLastValidCell(function (param) {
          
        });
    setCurrentWord(function (param) {
          return "";
        });
  };
  var handleSubmit = function () {
    var coordinates = Belt_List.toArray(Belt_List.map(Belt_List.reverse(selectedCells), (function (param) {
                return {
                        row: param[0],
                        col: param[1]
                      };
              })));
    var handleValidationResponse = function (json) {
      var validationResult = Belt_Option.flatMap(Js_json.decodeObject(json), (function (obj) {
              return Belt_Option.flatMap(Js_dict.get(obj, "isValid"), Js_json.decodeBoolean);
            }));
      if (validationResult !== undefined) {
        if (validationResult) {
          var isSpangram = Belt_Option.flatMap(Js_json.decodeObject(json), (function (obj) {
                  return Belt_Option.flatMap(Js_dict.get(obj, "isSpangram"), Js_json.decodeBoolean);
                }));
          var exit = 0;
          if (isSpangram !== undefined && isSpangram) {
            console.log("Spangram word!");
            setFoundWords(function (prev) {
                  return {
                          hd: currentWord,
                          tl: prev
                        };
                });
            setFoundCells(function (prev) {
                  return Belt_List.concatMany([
                              prev,
                              selectedCells
                            ]);
                });
            setSpangramCells(function (prev) {
                  return Belt_List.concatMany([
                              prev,
                              selectedCells
                            ]);
                });
            clearWord();
          } else {
            exit = 1;
          }
          if (exit === 1) {
            console.log("Valid word!");
            setFoundWords(function (prev) {
                  return {
                          hd: currentWord,
                          tl: prev
                        };
                });
            setFoundCells(function (prev) {
                  return Belt_List.concatMany([
                              prev,
                              selectedCells
                            ]);
                });
            clearWord();
          }
          
        } else {
          console.log("Invalid word!");
        }
      } else {
        console.error("Invalid validation response");
      }
      return Promise.resolve();
    };
    Core__Promise.$$catch(fetch("http://localhost:8080/initialize?mode=dynamic", Webapi__Fetch.RequestInit.make("Post", {
                      "Content-Type": "application/json",
                      "Access-Control-Allow-Methods": "POST",
                      "Access-Control-Allow-Origin": "http://127.0.0.1:5173"
                    }, Caml_option.some(Belt_Option.getWithDefault(JSON.stringify({
                                  word: currentWord,
                                  coordinates: coordinates
                                }), "{}")), undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined)).then(function (prim) {
                return prim.json();
              }).then(handleValidationResponse), (function (err) {
            console.error("Error validating word", err);
            return Promise.resolve();
          }));
  };
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsx("h1", {
                      children: "FP Strands - Static",
                      className: "text-2xl font-bold mb-4"
                    }),
                JsxRuntime.jsx("p", {
                      children: currentWord,
                      className: "text-center h-[30px]"
                    }),
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsx("div", {
                              children: JsxRuntime.jsx(Theme.make, {
                                    theme: "Let's strand"
                                  }),
                              className: "side-panel content-center"
                            }),
                        JsxRuntime.jsxs("div", {
                              children: [
                                JsxRuntime.jsx(Grid.make, {
                                      board: board,
                                      selectedCells: selectedCells,
                                      foundCells: match$5[0],
                                      spangramCells: match$6[0],
                                      onCellClick: handleCellClick
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
                                                  clearWord();
                                                })
                                            })
                                      ],
                                      className: "mt-4 flex gap-2 justify-center"
                                    })
                              ],
                              className: "grid-w-controls"
                            }),
                        JsxRuntime.jsx("div", {
                              children: JsxRuntime.jsx(Words.make, {
                                    foundWords: match$3[0]
                                  }),
                              className: "side-panel"
                            })
                      ],
                      className: "game-content"
                    })
              ],
              className: "content"
            });
}

var make = Dynamic;

export {
  make ,
}
/* Grid Not a pure module */
