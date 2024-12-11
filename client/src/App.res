open RescriptReactRouterDom.ReactRouterDOM


@react.component
let make = () => {
  <HashRouter>
    <div>
      <nav>
        <Link href="/">{"Home" |> React.string}</Link>
        <Link href="/static">{"Static" |> React.string}</Link>
        <Link href="/dynamic">{"Dynamic" |> React.string}</Link>
        <Link href="/playground">{"Playground" |> React.string}</Link>
      </nav>

      <Routes>
        <Route path="/" element={<Home.make />} />
        <Route path="/static" element={<Static.make />} />
        <Route path="/dynamic" element={<Dynamic.make />} />
        <Route path="/playground" element={<Playground.make />} />
      </Routes>
    </div>
  </HashRouter>
}
