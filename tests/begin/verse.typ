#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Verse] #label("org0000001")
Here we produce a non formatted and whites pace preserving block.

#figure([#raw(block: true, "jaksg  ksgj dkg dfg
dgds
g dfg d
 g d
 s fg
 dsfgdsgdsfg kjdfgdfg
 df g
 dsdsfg
 dsfg dsgds g")]) #label("org0000000")
