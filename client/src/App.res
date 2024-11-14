type response
@val external fetch: string => promise<response> = "fetch"
@send external json: response => promise<'a> = "json"

let makeRequest = async url => {
  let response = await fetch(url)
  let json = await response->json
  Js.log(json)
}

@react.component
let make = () => {
  let (count, setCount) = React.useState(() => 0)



  <div className="p-6">
    <h1 className="text-3xl font-semibold"> {"What is this about?"->React.string} </h1>
    <p>
      {React.string("This is a simple template for a Vite project using ReScript & Tailwind CSS.")}
    </p>
    <h2 className="text-2xl font-semibold mt-5"> {React.string("Fast Refresh Test")} </h2>
    <Button onClick={_ => setCount(count => count + 1)}>
      {React.string(`count is ${count->Int.toString}`)}
    </Button>
    <p>
      {React.string("Edit ") }
      <code> {React.string("src/App.res")} </code>
      {React.string(" and save to test Fast Refresh.")}
    </p>
    <h3 className="mt-4">{React.string("Fetched Name: ")}</h3>
  </div>
}
