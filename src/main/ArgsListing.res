
let listArgs: () => promise<array<Model.arg>> = () => {
  PageFetching.fetchArgsPageHTML()->Promise.thenResolve(htmlText => {
    PageParsing.htmlTextToArgs(~baseURL = "https://ww3.ca2.uscourts.gov", ~htmlText)
  })
}

