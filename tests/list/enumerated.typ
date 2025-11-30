#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Enumerated] #label("org0000000")
#enum(enum.item(1)[One],
enum.item(2)[Two
#enum(enum.item(1)[TwoPointOne],
enum.item(2)[TwoPointTwo],
)],
enum.item(3)[Three],
enum.item(4)[],
)
