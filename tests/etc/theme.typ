#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
// example theme inspired by the modus-theme

#let modus-themes-color-warm = rgb(93, 48, 38)
#let modus-themes-color-cold = rgb(9, 48, 96)
#let modus-themes-color-inlinecodefg = rgb(143, 0, 117)
#let modus-themes-color-baselinkfg = rgb(0, 49, 169)
#let modus-themes-color-codeblockbg = rgb(248, 248, 248)
#let modus-themes-color-black = rgb(0, 0, 0)
#let modus-themes-color-basefg = modus-themes-color-black
#let modus-themes-color-white-alt = rgb(240, 240, 240)
#let modus-themes-color-black-alt = rgb(89, 89, 89)
#let modus-themes-color-basebgalt = modus-themes-color-white-alt
#let modus-themes-color-basefgalt = modus-themes-color-black-alt
#let modus-themes-color-mild = rgb(24, 64, 52)

#set text(size: 12pt, font: "Noto Sans")
#set par(leading: 0.44em)
#show par: it => block(below: 1.44em, it)

#show link: set text(modus-themes-color-baselinkfg)
#show link: it => underline(it)
#show ref: set text(modus-themes-color-baselinkfg)

#set heading(numbering: "1.1.1.")
#show heading.where(level: 1): set text(modus-themes-color-warm, weight: 700, size: 1.45em)
#show heading.where(level: 2): set text(modus-themes-color-cold, weight: 700, size: 1.30em)
#show heading.where(level: 3): set text(modus-themes-color-mild, weight: 700, size: 1.15em)

#show outline: it => {text(modus-themes-color-baselinkfg, it)}
#show outline.entry: it => [ #h((it.level - 1) * 1em) #it #v(0.1em, weak: true)]

#show terms: it => block(above: 1.5em, it)

#show raw: set par(leading: 0.44em)
#show raw: it => if (it.has("block") and it.block) and (it.has("lang") and it.lang != none) [
#set align(left)
#block(
 fill: modus-themes-color-codeblockbg,
 inset: (top: 1em, bottom: 1em, left: 1.44em, right: 1.44em),
 stroke: (top: 5pt + modus-themes-color-basebgalt, bottom: 5pt + modus-themes-color-basebgalt),
 width: 100%,
 spacing: 1.44em,
 it)
] else {it}
#show raw: it => if (not it.has("block") or not it.block) and (not it.has("lang") or it.lang == none) {
text(modus-themes-color-inlinecodefg, size: 0.889em, it.text)
} else {it}

#set footnote.entry(
  separator: text(modus-themes-color-basefgalt, repeat[.])
)
#heading(level: 1)[Section 1] #label("org0000000")
Here should be some text
