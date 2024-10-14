#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Remote Image] #label("org0000007")
One image should not be inlined, since Typst does not understand it. The other
should be inlinded.
#heading(level: 2)[Not Included] #label("org0000000")
#link("\u{22}file:///./black.unknown\u{22}")
#heading(level: 2)[Included] #label("org0000004")
#figure([#image("/./black.png")]) #label("org0000003")
