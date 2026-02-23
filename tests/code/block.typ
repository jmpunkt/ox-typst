#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Block] #label("org0000001")
Here is how we define present code.

#figure([#raw(block: true, lang: "bash", "# print hi to console
echo \u{22}hi\u{22}")], caption: [Example Bash code.]) #label("org0000000")
