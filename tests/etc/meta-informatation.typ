#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set document(title: "My Cool Typst", author: "Me You")
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Section] #label("org0000000")
This should include meta information.
