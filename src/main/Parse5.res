
let todo = () => Exn.raiseError("Not implemented")

type seq<'t> = Seq.t<'t>

module Element = {
  type t
  type attr = {
    name: string,
    value: string
  }
  
  @get external nodeName: t => string = "nodeName"
  @get external tagName: t => string = "tagName"
  @get external attrs: t => array<attr> = "attrs"
  @get external childNodes: t => option<array<t>> = "childNodes"
  @get external value: t => option<string> = "value"
  
  let childrenWithTag: (t, string) => array<t> = (el, tag) =>
    el->childNodes->Option.map(c => c->Array.filter(ch => ch->tagName == tag))->Option.getOr([])
    
  let childrenWithNodeName: (t, string) => array<t> = (el, name) =>
    el->childNodes->Option.map(c => c->Array.filter(ch => ch->nodeName == name))->Option.getOr([])
    
  let rec walkTree: t => seq<t> = el => Seq.cons(
    el,
    Seq.flatten(Seq.fromArray(el->childNodes->Option.map(c => c->Array.map(walkTree))->Option.getOr([])))
  )
    
  let elementByTagName: (t, string) => option<t> = (el, tag) =>
    el->walkTree->Seq.find(el => el->tagName == tag)
}

type element = Element.t

module Document = {
  type t
  
  @get external childNodes: t => array<element> = "childNodes"
}

type document = Document.t

@module("parse5") external parse: string => document = "parse"
@module("parse5") external serialize: Element.t => string = "serialize"

