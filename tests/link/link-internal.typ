#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Link in Headline ] #label("org0000000")
Here without name #ref(label("org0000000")) and here with name #link(label("org0000000"))[My Custom Section Name].
