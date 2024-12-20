// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Cell from "./Cell.res.mjs";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as JsxRuntime from "react/jsx-runtime";

function Grid(props) {
  var onCellClick = props.onCellClick;
  var spangramCells = props.spangramCells;
  var foundCells = props.foundCells;
  var selectedCells = props.selectedCells;
  var isCellSelected = function (rowIndex, colIndex) {
    var coordinate = [
      rowIndex,
      colIndex
    ];
    return Belt_List.has(selectedCells, coordinate, Caml_obj.equal);
  };
  var isCellFound = function (rowIndex, colIndex) {
    var coordinate = [
      rowIndex,
      colIndex
    ];
    return Belt_List.has(foundCells, coordinate, Caml_obj.equal);
  };
  var isCellSpangram = function (rowIndex, colIndex) {
    var coordinate = [
      rowIndex,
      colIndex
    ];
    return Belt_List.has(spangramCells, coordinate, Caml_obj.equal);
  };
  return JsxRuntime.jsx("div", {
              children: JsxRuntime.jsx("div", {
                    children: Belt_Array.mapWithIndex(props.board, (function (rowIndex, row) {
                            return Belt_Array.mapWithIndex(row, (function (colIndex, letter) {
                                          return JsxRuntime.jsx(Cell.make, {
                                                      letter: letter,
                                                      isSelected: isCellSelected(rowIndex, colIndex),
                                                      isFound: isCellFound(rowIndex, colIndex),
                                                      isSpangram: isCellSpangram(rowIndex, colIndex),
                                                      onClick: (function () {
                                                          onCellClick(rowIndex, colIndex);
                                                        })
                                                    }, "cell-" + String(rowIndex) + "-" + String(colIndex));
                                        }));
                          })),
                    className: "grid grid-cols-6 gap-1 w-[300px]"
                  }),
              className: "flex justify-center"
            });
}

var make = Grid;

export {
  make ,
}
/* Cell Not a pure module */
