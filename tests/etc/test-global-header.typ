#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#[defined in the variable]
#outline()
#set heading(numbering: "1.")
