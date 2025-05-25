#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Smart Quotes] #label("org0000000")
The following should be quoted. Typst should be able to use smart quotes,
depending on the language settings.

"Hello World"

"Hello World isn't made of quotes"

'Alternative Hello World'

'Alternative with a a single quote e.g. "'
#heading(level: 1)[Single Smart Quotes] #label("org0000003")
This shouldn't be a problem as well.
