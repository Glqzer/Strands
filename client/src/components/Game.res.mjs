// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Grid from "./Grid.res.mjs";
import * as Theme from "./Theme.res.mjs";
import * as Words from "./Words.res.mjs";
import * as React from "react";
import * as Button from "./Button.res.mjs";
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

function Game(props) {
  var mode = props.mode;
  var match = React.useState(function () {
        return [];
      });
  var setBoard = match[1];
  var board = match[0];
  var match$1 = React.useState(function () {
        return "";
      });
  var setTheme = match$1[1];
  var match$2 = React.useState(function () {
        return /* [] */0;
      });
  var setSelectedCells = match$2[1];
  var selectedCells = match$2[0];
  var match$3 = React.useState(function () {
        
      });
  var setLastValidCell = match$3[1];
  var lastValidCell = match$3[0];
  var match$4 = React.useState(function () {
        return /* [] */0;
      });
  var setFoundWords = match$4[1];
  var match$5 = React.useState(function () {
        return "";
      });
  var setCurrentWord = match$5[1];
  var currentWord = match$5[0];
  var match$6 = React.useState(function () {
        return /* [] */0;
      });
  var setFoundCells = match$6[1];
  var match$7 = React.useState(function () {
        return /* [] */0;
      });
  var setSpangramCells = match$7[1];
  var match$8 = React.useState(function () {
        return "";
      });
  var setPlaygroundTheme = match$8[1];
  var playgroundTheme = match$8[0];
  var match$9 = React.useState(function () {
        return "";
      });
  var setPlaygroundSpangram = match$9[1];
  var playgroundSpangram = match$9[0];
  var match$10 = React.useState(function () {
        return false;
      });
  var setIsPlaygroundInitialized = match$10[1];
  var isPlaygroundInitialized = match$10[0];
  var gameInitialization = function (json) {
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
    var themeResult = Belt_Option.flatMap(Belt_Option.flatMap(Js_json.decodeObject(json), (function (obj) {
                return Js_dict.get(obj, "theme");
              })), Js_json.decodeString);
    if (boardResult !== undefined) {
      setBoard(function (param) {
            return boardResult;
          });
    } else {
      console.error("Failed to initialize board");
    }
    if (themeResult !== undefined) {
      setTheme(function (param) {
            return themeResult;
          });
    } else {
      console.error("Failed to retrieve theme");
    }
    return Promise.resolve();
  };
  React.useEffect((function () {
          var modeString = mode === "playground" ? "playground" : (
              mode === "dynamic" ? "dynamic" : "static"
            );
          Core__Promise.$$catch(fetch("http://localhost:8080/initialize?mode=" + modeString).then(function (prim) {
                      return prim.json();
                    }).then(gameInitialization), (function (err) {
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
          if (!prev) {
            return {
                    hd: coordinate,
                    tl: /* [] */0
                  };
          }
          var rest = prev.tl;
          if (lastValidCell !== undefined) {
            if (Caml_obj.equal(lastValidCell, coordinate)) {
              return rest;
            } else if (isAdjacent(lastValidCell, coordinate) && !Belt_List.has(selectedCells, coordinate, Caml_obj.equal)) {
              if (Caml_obj.equal(prev.hd, coordinate)) {
                return rest;
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
            return prev;
          }
        });
    if (lastValidCell !== undefined) {
      if (Caml_obj.equal(lastValidCell, coordinate)) {
        setCurrentWord(function (prev) {
              if (Belt_List.has(selectedCells, coordinate, Caml_obj.equal)) {
                return Js_string.slice(0, prev.length - 1 | 0, prev);
              } else {
                return prev + letter;
              }
            });
      } else if (isAdjacent(lastValidCell, coordinate) && !Belt_List.has(selectedCells, coordinate, Caml_obj.equal)) {
        setCurrentWord(function (prev) {
              return prev + letter;
            });
      } else {
        setCurrentWord(function (prev) {
              return prev;
            });
      }
    } else {
      setCurrentWord(function (prev) {
            return prev + letter;
          });
    }
    var secondToLast = Belt_List.get(selectedCells, 1);
    setLastValidCell(function (prev) {
          if (prev !== undefined) {
            if (Caml_obj.equal(prev, coordinate)) {
              if (secondToLast !== undefined) {
                return secondToLast;
              } else {
                return ;
              }
            } else if (isAdjacent(prev, coordinate) && !Belt_List.has(selectedCells, coordinate, Caml_obj.equal)) {
              return coordinate;
            } else {
              return prev;
            }
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
    var modeString = mode === "playground" ? "playground" : (
        mode === "dynamic" ? "dynamic" : "static"
      );
    Core__Promise.$$catch(fetch("http://localhost:8080/validate?mode=" + modeString, Webapi__Fetch.RequestInit.make("Post", {
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
  var handlePlaygroundInitialize = function () {
    var playgroundData = {
      theme: playgroundTheme,
      spangram: playgroundSpangram
    };
    Core__Promise.$$catch(fetch("http://localhost:8080/initialize-playground", Webapi__Fetch.RequestInit.make("Post", {
                        "Content-Type": "application/json",
                        "Access-Control-Allow-Methods": "POST",
                        "Access-Control-Allow-Origin": "http://127.0.0.1:5173"
                      }, Caml_option.some(Belt_Option.getWithDefault(JSON.stringify(playgroundData), "{}")), undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined)).then(function (prim) {
                  return prim.json();
                }).then(gameInitialization).then(function () {
              setIsPlaygroundInitialized(function (param) {
                    return true;
                  });
              return Promise.resolve();
            }), (function (err) {
            console.error("Error initializing playground", err);
            return Promise.resolve();
          }));
  };
  var pageTitle = mode === "playground" ? "FP Strands - Playground" : (
      mode === "dynamic" ? "FP Strands - Dynamic" : "FP Strands - Static"
    );
  var handleThemeChange = function ($$event) {
    var value = $$event.currentTarget.value;
    setPlaygroundTheme(function (param) {
          return value;
        });
  };
  var handleSpangramChange = function ($$event) {
    var value = $$event.currentTarget.value;
    setPlaygroundSpangram(function (param) {
          return value;
        });
  };
  var themeText = mode === "playground" && !isPlaygroundInitialized ? playgroundTheme : match$1[0];
  var tmp;
  var exit = 0;
  if (mode === "playground" && !isPlaygroundInitialized) {
    tmp = null;
  } else {
    exit = 1;
  }
  if (exit === 1) {
    tmp = JsxRuntime.jsxs(JsxRuntime.Fragment, {
          children: [
            JsxRuntime.jsx("div", {
                  children: JsxRuntime.jsx(Theme.make, {
                        theme: themeText
                      }),
                  className: "side-panel content-center"
                }),
            JsxRuntime.jsxs("div", {
                  children: [
                    JsxRuntime.jsx(Grid.make, {
                          board: board,
                          selectedCells: selectedCells,
                          foundCells: match$6[0],
                          spangramCells: match$7[0],
                          onCellClick: handleCellClick
                        }),
                    JsxRuntime.jsxs("div", {
                          children: [
                            JsxRuntime.jsx(Button.make, {
                                  type_: "clear",
                                  onClick: (function (param) {
                                      clearWord();
                                    }),
                                  children: "Clear"
                                }),
                            JsxRuntime.jsx(Button.make, {
                                  type_: "submit",
                                  onClick: (function (param) {
                                      handleSubmit();
                                    }),
                                  children: "Submit"
                                })
                          ],
                          className: "mt-4 flex gap-2 justify-center"
                        })
                  ],
                  className: "grid-w-controls"
                }),
            JsxRuntime.jsx("div", {
                  children: JsxRuntime.jsx(Words.make, {
                        foundWords: match$4[0]
                      }),
                  className: "side-panel"
                })
          ]
        });
  }
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsx("h1", {
                      children: pageTitle,
                      className: "text-2xl font-bold mb-4"
                    }),
                mode === "playground" ? JsxRuntime.jsxs("div", {
                        children: [
                          JsxRuntime.jsxs("div", {
                                children: [
                                  JsxRuntime.jsx("label", {
                                        children: "Theme",
                                        className: "block mb-2"
                                      }),
                                  JsxRuntime.jsx("input", {
                                        className: "border p-2 w-full",
                                        placeholder: "Enter Theme",
                                        type: "text",
                                        value: playgroundTheme,
                                        onChange: handleThemeChange
                                      })
                                ]
                              }),
                          JsxRuntime.jsxs("div", {
                                children: [
                                  JsxRuntime.jsx("label", {
                                        children: "Spangram",
                                        className: "block mb-2"
                                      }),
                                  JsxRuntime.jsx("input", {
                                        className: "border p-2 w-full",
                                        placeholder: "Enter Spangram",
                                        type: "text",
                                        value: playgroundSpangram,
                                        onChange: handleSpangramChange
                                      })
                                ]
                              }),
                          JsxRuntime.jsx("div", {
                                children: JsxRuntime.jsx(Button.make, {
                                      type_: "submit",
                                      onClick: (function (param) {
                                          handlePlaygroundInitialize();
                                        }),
                                      children: "Initialize Game"
                                    }),
                                className: "flex items-end"
                              })
                        ],
                        className: "playground-setup flex justify-center gap-4 mb-4"
                      }) : null,
                JsxRuntime.jsx("p", {
                      children: currentWord,
                      className: "text-center h-[30px]"
                    }),
                JsxRuntime.jsx("div", {
                      children: tmp,
                      className: "game-content"
                    })
              ],
              className: "content"
            });
}

var make = Game;

export {
  make ,
}
/* Grid Not a pure module */
