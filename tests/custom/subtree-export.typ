#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set document(title: "heading level 2")
#set text(lang: "en")
#set heading(numbering: "1.")
Content A
#heading(level: 1)[heading relative level 1] #label("org0000000")
Content B
