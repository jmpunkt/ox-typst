#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/../" --input file-0=/black.png
⁠```
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Image Outside of Typst Root] #label("org0000001")
Normally Typst only understands file which are relative to the project root
(called TYPST#sub[ROOT]).

#figure([#image(sys.inputs.file-0)]) #label("org0000000")
