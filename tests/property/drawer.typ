#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Drawer] #label("org0000001")
Still outside the drawer

This is inside the drawer.
 #label("org0000000")

After the drawer.
