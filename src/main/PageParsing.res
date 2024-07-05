
let x = Option.getExn
let todo = () => Exn.raiseError("Not implemented")
let oToA: option<'t> => array<'t> = o => switch o {
  | None => []
  | Some(x) => [x]
}

/*
  <table width=100% border="1">
  <tr>
  <td width="25%"><b><a href="/decisions/isysquery/1a402dba-08bd-4cc0-b264-e89dcac66e5a/8/doc/23-608.mp3"><nobr>23-608</a></b></td>
  <td width="25%">Adams v. Equinox Holdings, Inc.</td>
  <td width="25%" align="center">4-18-24</td>
  <td width="25%" align="center"><audio controls preload="none"><source src="/decisions/isysquery/1a402dba-08bd-4cc0-b264-e89dcac66e5a/8/doc/23-608.mp3" type="audio/mpeg"></audio></td>
  </tr>
  </table>
*/
type argTable = {
  mp3RelativeURL: string,
  caption: string,
  dateMDYString: string
}

let recognizeArgTable: Parse5.element => option<argTable> = table =>
  (table->Parse5.Element.elementByTagName("tr"))->Option.flatMap(tr => {
    let tds = tr->Parse5.Element.childrenWithTag("td")
    if tds->Array.length < 3 {
      None
    }
    else {
      let td0 = tds[0]->x
      let td1 = tds[1]->x
      let td2 = tds[2]->x
      
      td0->Parse5.Element.elementByTagName("a")->Option.flatMap(a => {
        a->Parse5.Element.attrs->Array.findMap(({name, value}) => {
          if name == "href" {
            Some(value)
          }
          else {
            None
          }
        })->Option.flatMap(mp3RelativeURL => {
          (td1->Parse5.Element.childrenWithNodeName("#text"))[0]->Option.flatMap(textNode => {
            textNode->Parse5.Element.value->Option.flatMap(caption => {
              (td2->Parse5.Element.childrenWithNodeName("#text"))[0]->Option.flatMap(textNode => {
                textNode->Parse5.Element.value->Option.flatMap(dateMDYString => {
                  Some({
                    mp3RelativeURL,
                    caption,
                    dateMDYString
                  })
                })
              })
            })
          })
        })
      })
    }
  })

let makeGUID = (~mp3RelativeURL: string, ~caption: string, ~dateMDYString: string) => {
  let fixedMP3RelativeURL = {
    // /decisions/isysquery/1a402dba-08bd-4cc0-b264-e89dcac66e5a/1/doc/23-6344.mp3
    switch RegExp.exec(%re("/^(.*\bisysquery\/).*?\/.*?\/(.*)$/"), mp3RelativeURL) {
      | Some(m) => {
        switch m->RegExp.Result.matches {
          | [before, after] => `${before}${after}`
          | _ => ""
        }
      }
      | None => ""
    }
  }
  
  `${fixedMP3RelativeURL}/${caption}/${dateMDYString}`
}
  
let argTableToArg: (string, argTable) => option<Model.arg> = (baseURL, {mp3RelativeURL, caption, dateMDYString}) => {
  RegExp.exec(%re("/(\d+)\-(\d+)\-(\d+)/"), dateMDYString)->Option.flatMap(dateMatch => {
    switch dateMatch->RegExp.Result.matches {
      | [sMonth, sDay, sYear] => {
        let month1Based = sMonth->Int.fromString->x
        let day1Based = sDay->Int.fromString->x
        let year = (sYear->Int.fromString->x) + 2000
        
        let date = Js.Date.makeWithYMD(~year=year->Int.toFloat, ~month=(month1Based-1)->Int.toFloat, ~date=day1Based->Int.toFloat, ())
        
        let mp3URL = `${baseURL}${mp3RelativeURL}`
        
        Some({
          Model.caption: caption,
          date,
          mp3URL,
          Model.guid: makeGUID(~mp3RelativeURL, ~caption, ~dateMDYString)
        })
      }
      | _ => None
    }
  })
}
  
let htmlTextToArgs: (~baseURL: string, ~htmlText: string) => array<Model.arg> = (~baseURL, ~htmlText) => {
  let doc = Parse5.parse(htmlText)
  let html = (doc->Parse5.Document.childNodes)[0]->x
  let body = (html->Parse5.Element.childrenWithTag("body"))[0]->x
  let tables =  body->Parse5.Element.childrenWithTag("table")
  let argTables = tables->Array.flatMap(table => recognizeArgTable(table)->oToA)
  let args = argTables->Array.flatMap(argTable => argTableToArg(baseURL, argTable)->oToA)
  args
}

