#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Plain] #label("org0000000")
#list(list.item[One])#list(list.item[Two
#list(list.item[TwoPointOne])#list(list.item[TwoPointTwo])])#list(list.item[Three])
