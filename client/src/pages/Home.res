open RescriptReactRouterDom.ReactRouterDOM

@react.component
let make = () => {
  <div className="content">
    <div className="items-center justify-center flex flex-col mb-10 h-full">
        <h1>{React.string("Welcome to FP Strands!")}</h1>
        <p>{React.string("A project by Mia Choi, Emma Levitsky, Tam Nguyen, and David Wang.")}</p>
        <div className="flex mt-5 gap-3">
        <Button type_="static">
            <Link href="/static">{"Static Example" |> React.string}</Link>
        </Button>
        <Button type_="dynamic">
            <Link href="/dynamic">{"Dynamic Example" |> React.string}</Link>
        </Button>
        </div>
    </div>
  </div>
}
