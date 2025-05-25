#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Description] #label("org0000000")
#terms(terms.item[Elijah Wood][He plays Frodo],
terms.item[Sean Astin][He plays Sam, Frodo\u{27}s friend.  I still remember him very well
from his role as Mikey Walsh in #emph[The Goonies].],
)
