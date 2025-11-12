#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./" --input file-1=/cite-other.bib --input file-0=/cite.bib
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#bibliography(style: "apa", (sys.inputs.file-0, sys.inputs.file-1))
#heading(level: 1)[Cite] #label("org0000000")
We can cite successfully from multiple bibliographies. Here is a cite from our
first bibliography #cite(label("DUMMY:1")). But we can also reference another
bibliography like this #cite(label("ANOTHER")).
