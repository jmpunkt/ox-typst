#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Schedule] #label("org0000003")
#heading(level: 2)[Call Trillian for a date on New Years Eve.] #label("org0000000")
DEADLINE: #datetime(year: 2004, month: 2, day: 29).display()
