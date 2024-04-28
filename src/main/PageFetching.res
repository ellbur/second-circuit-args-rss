
let fetchArgsPageHTML: () => promise<string> = async () => {
  let url = "https://ww3.ca2.uscourts.gov/decisions"

  let postData = "IW_SORT=-DATE&IW_BATCHSIZE=10&IW_FILTER_DATE_BEFORE=&IW_FILTER_DATE_AFTER=NaNNaNNaN&IW_FIELD_TEXT=*&IW_DATABASE=Oral+Args&opinion=*"

  let userAgent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"

  let response = await Axios.post(url, postData, { headers: { "User-Agent": userAgent } })

  response.data
}

