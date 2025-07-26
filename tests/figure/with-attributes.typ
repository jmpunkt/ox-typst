#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./" --input file-0\=/black.png
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Figure With Attributes] #label("org0000001")
It is also possible to specify the Typst arguments for a figure.

#figure([#image(sys.inputs.file-0, width: 32pt, height: 32pt, alt: "\u{22}Black Rectangle\u{22}", fit: "stretch")]) #label("org0000000")
