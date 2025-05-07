#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#bibliography(style: "apa", title: "Custom Ttitle For The Bibliography", ("cite.bib"))
#heading(level: 1)[Cite] #label("org0000000")
Here is my cite #cite(label("DUMMY:1")). But here is another cite with a
different style #cite(label("OTHER"), style: "ieee").


We can also use the two cites in a single link #cite(label("OTHER"), style: "ieee")#cite(label("DUMMY:1"), style: "ieee").
