#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Section One] #label("org0000000")
Lets see if that works if we can link the section with its full name like:
#ref(label("org0000000")). Now we want a name custom name like: #link(label("org0000000"))[Goto Heading]
