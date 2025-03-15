#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#set heading(numbering: "1.")
#outline(title: none)
#heading(level: 1)[A] #label("org0000007")
#heading(level: 2)[A1] #label("org0000004")
#figure([#table(columns: 3, [Name],[Phone],[Age],
[Peter],[1234],[17],
[Anna],[4321],[25],
)], caption: [This is an example table.]) #label("org0000000")
#heading(level: 3)[A11] #label("org0000001")
This should include all levels.
#heading(level: 1)[B] #label("org000000a")
#figure(circle(radius: 50pt), caption: [Large circle])
#heading(level: 1)[XX] #label("org000000d")

#heading(level: 1)[C] #label("org0000011")
#figure([#raw(block: true, lang: "lisp", "(message \u{22}hi\u{22})")], caption: [This is example code.]) #label("org0000010")
#heading(level: 1)[TOC] #label("org0000014")
#outline(title: none, target: figure.where(kind: image))
#outline(title: none, target: figure.where(kind: table))
#outline(title: none, target: figure.where(kind: raw))
