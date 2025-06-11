#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Quote] #label("org0000008")
#heading(level: 2)[With Attribution] #label("org0000001")
#figure([#quote(block: true, attribution: "Albert Einstein")[Everything should be made as simple as possible,
but not any simpler
]]) #label("org0000000")
#heading(level: 2)[Without Attribution] #label("org0000005")
#figure([#quote(block: true)[Everything should be made as simple as possible,
but not any simpler \u{2d}\u{2d}  Albert Einstein
]], outlined: false) #label("org0000004")
