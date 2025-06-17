#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#bibliography(style: "apa", title: "Custom Title For The Bibliography", ("cite.bib"))
#heading(level: 1)[Cite] #label("org0000003")
There are many ways to cite something. Here is a single cite #cite(label("OTHER")). It
is also possible to cite two times in a single element #cite(label("OTHER"))#cite(label("DUMMY:1")).
We can also change the style of a single cite #cite(label("OTHER"), form: "year").
Or add a suffix to the cite, like a page or paragraph #cite(label("DUMMY:1"), supplement: "p. 233").

It is also possible to use all features at the same time or mix them
#cite(label("OTHER"), form: "prose")#cite(label("DUMMY:1"), supplement: "p. 1337", form: "prose").
#heading(level: 2)[Cite Styles] #label("org0000000")
We map the style of Emacs to Typst:
#list(list.item[#cite(label("OTHER"), form: "prose")])#list(list.item[#cite(label("OTHER"), form: "author")])#list(list.item[#cite(label("OTHER"), form: "year")])#list(list.item[#cite(label("OTHER"), form: none)])#list(list.item[#cite(label("OTHER"), form: "normal")])
