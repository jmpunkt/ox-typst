#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set document(title: "", author: "unknown")
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[One] #label("org0000006")
#heading(level: 2)[One.One] #label("org0000003")
#heading(level: 3, outlined: false, numbering: none)[One.One.One] #label("org0000000")
#heading(level: 1)[Two] #label("org000000c")
#heading(level: 2)[Two.One] #label("org0000009")
Text.
