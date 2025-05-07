#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/../" --input file-0\=/link/cite.bib
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#bibliography(style: "apa", title: "Custom Ttitle For The Bibliography", "../link/cite.bib")
#heading(level: 1)[Cite Outside] #label("org0000000")
Here is my cite #cite(label("DUMMY:1")). But here is another cite with a
different style #cite(label("OTHER"), style: "ieee").

However, the bibliography is outside of the current directory, thus the project
root.
