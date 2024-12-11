@react.component
let make = (
  ~theme: string, 
) => {
    <div className="theme">
      <h2 className="text-xl font-semibold">{React.string("Theme:")}</h2>
      <h1>{React.string(theme)}</h1>
    </div>
}