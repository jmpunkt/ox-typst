#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[some tiny task] #label("org0000000")
This is a paragraph, it lies outside the inlinetask above.
#heading(level: 1)[some small task] #label("org0000003")
And here is some extra text
#heading(level: 1)[END] #label("org0000006")
