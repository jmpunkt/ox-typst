#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Math (pandoc)] #label("org0000000")
$ x = sqrt(b) $

This is inline Math: $a^2 = b$. The following two statements are not inlined.

$a + b$ $ a = - 2 $
