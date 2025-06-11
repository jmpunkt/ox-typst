#let _ = ```typ
exec typst c --root .                                  $0
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Test Root] #label("org0000000")
When supplying #raw("--root") inside the compile argument, then we should not try to
find the optimal root path. Notice that the new command includes a few
whitespaces.
