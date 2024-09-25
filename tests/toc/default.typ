#set text(lang: "en")
#set heading(numbering: "1.")
#outline(title: none)
#heading(level: 1)[A] <org0000007>
#heading(level: 2)[A1] <org0000004>
#figure([#table(columns: 3, [Name],[Phone],[Age],
[Peter],[1234],[17],
[Anna],[4321],[25],
)], caption: [This is an example table.]) <org0000000>
#heading(level: 3)[A11] <org0000001>
This should include all levels.
#heading(level: 1)[B] <org000000a>
#figure(circle(radius: 50pt), caption: [Large circle])
#heading(level: 1)[XX] <org000000d>

#heading(level: 1)[C] <org0000011>
#figure([#raw(block: true, lang: "lisp", "(message \u{22}hi\u{22})")], caption: [This is example code.]) <org0000010>
#heading(level: 1)[TOC] <org0000014>
#outline(title: none, target: figure.where(kind: image))
#outline(title: none, target: figure.where(kind: table))
#outline(title: none, target: figure.where(kind: raw))
