#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Fixed Width] #label("org0000000")
#raw(block: false, "This text section uses a fixed-width font.")
#heading(level: 1)[Section] #label("org0000003")
The previous section should contain a fixed width element.
