#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
= \u{23}1 Heading <org0000000>
I wonder if this is correct \u{23}1. We have to ensure that the character \u{23}" is
escaped correctly. Currently the character is escaped using the Unicode
escape. If we do not escape the character, then one could write raw Typst
statements. The resulting code would not compile properly.
