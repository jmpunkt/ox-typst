#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#set heading(numbering: "1.")
#outline(title: none)
#heading(level: 1)[A] #label("org0000006")
#heading(level: 2)[A1] #label("org0000003")
#heading(level: 3)[A11] #label("org0000000")
#heading(level: 1, outlined: false, numbering: none)[B] #label("org000000c")
#heading(level: 2, outlined: false, numbering: none)[B1] #label("org0000009")
#heading(level: 1)[C] #label("org000000f")
