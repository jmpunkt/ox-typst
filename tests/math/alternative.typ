#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Math] #label("org0000000")
Currently Typst Math is not recoginized. It is possible to write Typst math directly in Org.

$2 * 2$

When you are using the Typst syntax like this

\u{24} 2 \u{2a} 2 \u{24}

then this is not exported as math. It will be exported as normal text since Org does not recognize this as math code.

To be safe that this behavior does not break in the future, one should use an export block.

$ 1 * 1 $

And here is some \u{24} dollar symbol.
