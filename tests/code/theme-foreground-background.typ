#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Theme With Foreground And Background] #label("org0000001")
This theme has a foreground and background specified. However, Typst does not
apply these colors by default.

#list(list.item[background should be dark])#list(list.item[braces (all non keywords or constants) should be pink])

#figure([#block(fill: rgb(34, 34, 34), inset: 4pt)[#text(fill: rgb(255, 0, 149))[#raw(block: true, lang: "c", theme: "different-theme-color.xml","if (true) {} else {}")]]]) #label("org0000000")
