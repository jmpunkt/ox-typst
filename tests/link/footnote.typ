#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Footnote] #label("org0000003")
#list(list.item[Lets reference our definition #footnote(label("A"))])#list(list.item[COOL INLINE #footnote[ This is the inline definition of this footnote]])#list(list.item[COOL ELSE #footnote[ a definition] #label("ANYTHING")])#list(list.item[COOL TEST #footnote[ a definition with \u{23}1] #label("ANYTHING")])
#heading(level: 2)[Definitions] #label("org0000000")
#hide[#footnote[Let #raw("A") be defined here.] #label("A")]
