#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[File Links] #label("org0000000")
The bibliography is #link("./cite.typ"), this shouldn't be treated as an image.
