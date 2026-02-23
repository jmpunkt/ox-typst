#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Inline] #label("org0000000")
So this should be inline now #raw(block: false, lang: "sh", "echo \u{22}inline\u{22}"). Lets see if that
works.
