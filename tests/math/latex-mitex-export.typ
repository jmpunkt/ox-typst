#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#import "@preview/mitex:0.2.4": *
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Math (naive)] #label("org0000000")
#mitex(`\begin{equation}                        % arbitrary environments,
x=\sqrt{b}                              % even tables, figures, etc
\end{equation}
`)

This is inline Math: #mitex(`$a^2=b$`). The following two statements are not inlined.

#mitex(`\( a + b \)`) #mitex(`\[ a=-2 \]`)
