open RescriptReactRouterDom.ReactRouterDOM

@react.component
let make = () => {
  <div className="content">
    <div className="items-center justify-center flex flex-col mb-10 h-full">
        <h1>{React.string("Welcome to FP Strands!")}</h1>
        <p>{React.string("A project by Mia Choi, Emma Levitsky, Tam Nguyen, and David Wang.")}</p>
        <div className="flex mt-5 gap-3">
        <Link href="/static">
          <Button type_="static">
              {"Static Example" |> React.string}
          </Button>
        </Link>
        <Link href="/dynamic">
          <Button type_="dynamic">
              {"Dynamic Example" |> React.string}
          </Button>
        </Link>
        </div>
    </div>
  </div>
}
