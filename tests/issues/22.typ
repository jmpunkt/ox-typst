#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set document(title: "", author: "Shaul")
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Brackets Are Escaped] #label("org0000000")
Text with a bracket \u{5b}1\u{5d} and a lone \u{5d} and a lone \u{5b}.

#list(list.item[An item with \u{5b}brackets\u{5d} inside])#list(list.item[An item with a lone \u{5d}])
