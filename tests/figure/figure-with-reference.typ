#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./" --input file-0=/black.png
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Figure] #label("org0000002")
Now lets insert a black rectangle.

#figure([#image(sys.inputs.file-0)], caption: [Wow look at this black rectangle. This is another caption for the same black rectangle.]) #label("org0000000")

Here is a reference to #ref(label("org0000000"))
