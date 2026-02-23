#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#show link: set text(fill: blue, weight: 700)
#show link: underline
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Emacs Syntax Highlighting] #label("org0000001")
#{ show raw.line: it => { 
if it.number == 1 { 
[#text(fill: rgb(255, 192, 203),weight: "bold","echo")]
" hi" } } 
[#figure([#raw(block: true, lang: "sh", "echo hi")]) #label("org0000000")] }
