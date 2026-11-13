#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set document(title: "", author: "Shaul")
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Headings Below Level One] #label("org0000000")
Text with a footnote#footnote(label("1")).
#heading(level: 1)[Second] #label("org0000003")
More text.
#heading(level: 1, outlined: false, numbering: none)[Footnotes] #label("org0000006")
#hide[#footnote[A plain footnote.] #label("1")]
