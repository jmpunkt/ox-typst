#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Linebreak] #label("org0000000")
This is a line break. #linebreak()
We should also be able to have the two in a row #linebreak()
#linebreak()
#linebreak()
Above there should be empty lines.
