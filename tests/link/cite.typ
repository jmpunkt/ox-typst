#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#bibliography(style: "apa", title: "Custom Title For The Bibliography", ("cite.bib"))
#heading(level: 1)[Cite] #label("org0000000")
Here is my cite #cite(label("DUMMY:1"), supplement: "p. 233"). #cite(label("OTHER"), form: "prose") agrees.
