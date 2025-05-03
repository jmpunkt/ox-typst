#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#set heading(numbering: "1.")
#outline(title: none, target: figure.where(kind: table))
#heading(level: 1)[A] #label("org0000002")
#figure([#table(columns: 3, [Name],[Phone],[Age],
[Peter],[1234],[17],
[Anna],[4321],[25],
)], caption: [This is the first table], outlined: false) #label("org0000000")

#figure([#table(columns: 3, [Name],[Phone],[Age],
[Peter],[1234],[17],
[Anna],[4321],[25],
)], caption: [This is the second table]) #label("org0000001")
