#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[First Page] #label("org0000002")
#figure([#raw(block: true, lang: "bash", "# print hi to console
echo \u{22}hi\u{22}")]) #label("org0000000")


#pagebreak()
#heading(level: 1)[Second Page] #label("org0000005")
This should get us to the first page #ref(label("org0000000")).
