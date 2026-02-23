#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Link] #label("org0000000")
Maybe found here #link("http://google.com")[Google] :)

Or we put a link here #link("https://google.com").
