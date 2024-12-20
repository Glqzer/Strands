// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Button from "../components/Button.res.mjs";
import * as JsxRuntime from "react/jsx-runtime";
import * as ReactRouterDOM$RescriptReactRouterDom from "rescript-react-router-dom/src/ReactRouterDOM.res.mjs";

function Home(props) {
  return JsxRuntime.jsx("div", {
              children: JsxRuntime.jsxs("div", {
                    children: [
                      JsxRuntime.jsx("h1", {
                            children: "Welcome to FP Strands!",
                            className: "mb-2"
                          }),
                      JsxRuntime.jsx("p", {
                            children: "A project by Mia Choi, Emma Levitsky, Tam Nguyen, and David Wang."
                          }),
                      JsxRuntime.jsxs("div", {
                            children: [
                              JsxRuntime.jsx(ReactRouterDOM$RescriptReactRouterDom.Link.make, {
                                    children: JsxRuntime.jsx(Button.make, {
                                          type_: "static",
                                          children: "Static Example"
                                        }),
                                    href: "/static"
                                  }),
                              JsxRuntime.jsx(ReactRouterDOM$RescriptReactRouterDom.Link.make, {
                                    children: JsxRuntime.jsx(Button.make, {
                                          type_: "dynamic",
                                          children: "Dynamic Example"
                                        }),
                                    href: "/dynamic"
                                  }),
                              JsxRuntime.jsx(ReactRouterDOM$RescriptReactRouterDom.Link.make, {
                                    children: JsxRuntime.jsx(Button.make, {
                                          type_: "playground",
                                          children: "Playground (WIP)"
                                        }),
                                    href: "/playground"
                                  })
                            ],
                            className: "flex mt-8 gap-3 pb-3"
                          }),
                      JsxRuntime.jsxs("div", {
                            children: [
                              JsxRuntime.jsx(ReactRouterDOM$RescriptReactRouterDom.Link.make, {
                                    children: JsxRuntime.jsx(Button.make, {
                                          type_: "slides",
                                          children: "Slides"
                                        }),
                                    href: "https://docs.google.com/presentation/d/1xT0PUwfyjzmyGQCqzjY8QlT6CK9bhEygvlbUAsKF6L4/edit?usp=sharing"
                                  }),
                              JsxRuntime.jsx(ReactRouterDOM$RescriptReactRouterDom.Link.make, {
                                    children: JsxRuntime.jsx(Button.make, {
                                          type_: "github",
                                          children: "Github"
                                        }),
                                    href: "https://github.com/Glqzer/Strands"
                                  })
                            ],
                            className: "flex mt-2 gap-3"
                          })
                    ],
                    className: "items-center justify-center flex flex-col h-full"
                  }),
              className: "content h-screen"
            });
}

var make = Home;

export {
  make ,
}
/* Button Not a pure module */
