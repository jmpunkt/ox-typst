#set text(lang: "en")
#set heading(numbering: "1.")
#outline(title: none)
= A <org0000006>
== A1 <org0000003>
#figure([#table(columns: 3, [Name],[Phone],[Age],
[Peter],[1234],[17],
[Anna],[4321],[25],
)], caption: [This is an example table.])
=== A11 <org0000000>
This should include all levels.
= B <org0000009>
#figure(circle(radius: 50pt), caption: [Large circle])
= XX <org000000c>

= C <org000000f>
#figure([#raw(block: true, lang: "lisp", "(message \u{22}hi\u{22})")], caption: [This is example code.])
= TOC <org0000012>
#outline(title: none, target: figure.where(kind: image))
#outline(title: none, target: figure.where(kind: table))
#outline(title: none, target: figure.where(kind: raw))
