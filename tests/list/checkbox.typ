#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Checkbox] #label("org0000000")
#list(marker: [#box(stroke: 0.5pt + rgb(0,0,0), width: 8pt, height: 8pt, align(center, " "))], list.item[One])#list(marker: [#box(stroke: 0.5pt + rgb(0,0,0), width: 8pt, height: 8pt, align(center, "+"))], list.item[Two])#list(marker: [#box(stroke: 0.5pt + rgb(0,0,0), width: 8pt, height: 8pt, align(center, "-"))], list.item[Other
#list(marker: [#box(stroke: 0.5pt + rgb(0,0,0), width: 8pt, height: 8pt, align(center, " "))], list.item[OtherOne])#list(marker: [#box(stroke: 0.5pt + rgb(0,0,0), width: 8pt, height: 8pt, align(center, "+"))], list.item[OtherTwo])])
