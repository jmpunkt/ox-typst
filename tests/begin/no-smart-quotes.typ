#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[No Smart Quotes] #label("org0000000")
When smart quotes are disabled, then the output must be escaped.

\u{22}Hello World\u{22}

\u{22}Hello World isn\u{27}t made of quotes\u{22}

\u{27}Alternative Hello World\u{27}

\u{27}Alternative with a a single quote e.g. \u{22}\u{27}
#heading(level: 1)[Single Smart Quotes] #label("org0000003")
This shouldn\u{27}t be a problem as well.
