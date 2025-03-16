#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Clock] #label("org0000003")
Here we have an example task with time information. Lets see how this is
represented in Typst.
#heading(level: 3)[Some task] #label("org0000000")
#list(list.item[State "DONE"       from "TODO"       #datetime(year: 2020, month: 12, day: 7, hour: 2, minute: 26, second: 0).display()])
