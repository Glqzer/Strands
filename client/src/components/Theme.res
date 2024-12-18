@react.component
let make = (
  ~theme: string, 
) => {
    <div className="theme">
      <h2 className="text-xl font-semibold text-center bg-sky-200 rounded-t-lg py-1">{React.string("Theme:")}</h2>
      <h1 className="px-5 py-4">{React.string(theme)}</h1>
    </div>
}