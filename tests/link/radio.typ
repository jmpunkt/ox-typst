#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Radio Target] #label("org0000000")
Go to #link(label("org0000000"))[Radio Target] for more information.
#heading(level: 1)[#underline[Radio Targets]] #label("org0000004")
Go to #link(label("org0000004"))[Radio Targets] for more underlined information.
#heading(level: 1)[Radio in Text] #label("org0000009")
Go to This #label("org0000008") for more information about #link(label("org0000008"))[This].
