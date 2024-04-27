
let x = Option.getExn

let docText = `
<html>
  <body>
    <table width=100%>
    </table>
  </body>
</html>
`

let doc = Parse5.parse(docText)
let html = (doc->Parse5.Document.childNodes)[0]->x
let table =  html->Parse5.Element.elementByTagName("table")

Console.log(table)
Console.log(table->x->Parse5.Element.attrs)

