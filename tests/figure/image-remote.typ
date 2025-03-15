#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./" --input file-0\=black.png
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Remote Image] #label("org0000007")
One image should not be inlined, since Typst does not understand the file
ending. The other should be inlined.
#heading(level: 2)[Not Included] #label("org0000000")
#link("file:black.unknown")
#heading(level: 2)[Included] #label("org0000004")
#figure([#image(sys.inputs.file-0)]) #label("org0000003")
