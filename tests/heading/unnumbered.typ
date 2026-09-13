#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set document(title: "", author: "unknown")
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1, outlined: false, numbering: none)[One] #label("org0000003")
#heading(level: 2, outlined: false, numbering: none)[One.One] #label("org0000000")
Text.
#heading(level: 1)[Two] #label("org0000009")
#heading(level: 2)[Two.One] #label("org0000006")
Text.
