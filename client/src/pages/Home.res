open RescriptReactRouterDom.ReactRouterDOM

@react.component
let make = () => {
  <div className="content h-screen">
    <div className="items-center justify-center flex flex-col h-full">
        <h1 className="mb-2">{React.string("Welcome to FP Strands!")}</h1>
        <p>{React.string("A project by Mia Choi, Emma Levitsky, Tam Nguyen, and David Wang.")}</p>
        <div className="flex mt-8 gap-3 pb-20">
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
        <Link href="https://docs.google.com/presentation/d/1xT0PUwfyjzmyGQCqzjY8QlT6CK9bhEygvlbUAsKF6L4/edit?usp=sharing">
          <Button type_="slides">
              {"Slides" |> React.string}
          </Button>
        </Link>
        <Link href="https://github.com/Glqzer/Strands">
          <Button type_="github">
              {"Github" |> React.string}
          </Button>
        </Link>
        </div>
    </div>
  </div>
}
