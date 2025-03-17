#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Table] #label("org0000001")
#raw("The following table contains verbatim content")

#figure([#table(columns: 2, [\u{23}A],[#raw("Verbatim")],
[1],[2],
[6],[7],
)], caption: [special table]) #label("org0000000")
