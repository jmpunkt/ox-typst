#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Dollar Is Not Escaped] #label("org0000006")
Some inline math $x != y$.

Some dollar sign \u{24}.
#heading(level: 2)[What about some \u{24} in the Title] #label("org0000000")

#heading(level: 2)[Nice formula in the title $x=1$] #label("org0000003")
