#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set document(title: "", author: "Shaul")
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Trailing Backslash] #label("org0000000")
A line that ends with a backslash \u{5c}
and the next line follows.

#enum(enum.item(1)[First item ending with a backslash \u{5c}],
enum.item(2)[Second item],
)
