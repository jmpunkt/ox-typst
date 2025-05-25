#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./" --input file-3\=/different-theme-syntax.yml --input file-2\=/different-theme-color.xml --input file-1\=/different-theme-syntax.yml --input file-0\=/different-theme-color.xml
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Override Listing Theme] #label("org0000018")
#heading(level: 2)[Default Without Changes] #label("org0000001")
#figure([#raw(block: true, lang: "c", "if (true) {} else {}")]) #label("org0000000")
#heading(level: 2)[Mapping (elips \u{2d}\u{3e} lisp)] #label("org0000005")
#figure([#raw(block: true, lang: "lisp", "(error \u{22}hmm\u{22})")]) #label("org0000004")
#heading(level: 2)[Custom Theme And Syntax] #label("org0000009")
#list(list.item[\u{60}if\u{60} and else \u{60}else\u{60} should be highlighted in blue (color of the custom theme).])

#figure([#raw(block: true, lang: "cool", theme: sys.inputs.file-0,syntaxes: sys.inputs.file-1,"if (true) {} else {}")]) #label("org0000008")
#heading(level: 2)[Custom Theme] #label("org000000d")
#list(list.item[\u{60}if\u{60} and else \u{60}else\u{60} should be highlighted in blue (color of the custom theme).])#list(list.item[\u{60}true\u{60} should be highlighted in cyan (color of the custom theme).])

#figure([#raw(block: true, lang: "c", theme: sys.inputs.file-2,"if (true) {} else {}")]) #label("org000000c")
#heading(level: 2)[Custom Syntax File] #label("org0000011")
#list(list.item[\u{60}if\u{60} and else \u{60}else\u{60} should be highlighted in red (color of built\u{2d}in theme).])

#figure([#raw(block: true, lang: "cool", syntaxes: sys.inputs.file-3,"if (true) {} else {}")]) #label("org0000010")
#heading(level: 2)[Disable Syntax Highlighting] #label("org0000015")
#figure([#raw(block: true, lang: "c", theme: none,"if (true) {} else {}")]) #label("org0000014")
