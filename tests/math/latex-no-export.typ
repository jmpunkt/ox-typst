#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Math (no export)] #label("org0000000")
This is inline Math, but there is nothing here. . The following two
statements are not there either, strange.
