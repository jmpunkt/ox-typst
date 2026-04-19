#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Entities] #label("org0000000")
1\u{a2}.
100\u{20ac}.
1.5em space:\u{2002}\u{2002}\u{2002}here, all three spaces in =\u{2002}\u{2002}\u{2002}= constitute the entity name.
