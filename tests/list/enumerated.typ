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
)
#heading(level: 1)[Enumerated With Attributes] #label("org0000003")
#enum(tight: true, full: true, indent: 3pt, body-indent: 2pt, spacing: 1pt, number-align: bottom, enum.item(1)[One],
enum.item(2)[Two
#enum(enum.item(1)[TwoPointOne],
enum.item(2)[TwoPointTwo],
)],
enum.item(3)[Three],
)
