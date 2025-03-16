#let _ = ```typ
exec typst c "$0" --root "$(readlink -f "$0" | xargs dirname)/./"
⁠```
#set text(lang: "en")
#outline()
#set heading(numbering: "1.")
#heading(level: 1)[Clocktable] #label("org0000010")
#figure([#table(columns: 4, [Headline],[Time],[],[],
[#text(weight: "bold", [Total time])],[#text(weight: "bold", [3:54])],[],[],
[Clocktable],[3:54],[],[],
[\u{2002}\u{2002}Header one],[],[2:34],[],
[\u{2002}\u{2002}Another header],[],[0:20],[],
[\u{2002}\u{2002}\u{2002}\u{2002}Wow whats this],[],[],[0:10],
[\u{2002}\u{2002}A task],[],[1:00],[],
)], caption: [Clock summary at #datetime(year: 2023, month: 7, day: 10, hour: 2, minute: 29, second: 0).display()]) #label("org0000000")
#heading(level: 2)[Single] #label("org0000001")
:CLOCK: #datetime(year: 2016, month: 7, day: 23, hour: 18, minute: 24, second: 0).display() =>  1:14
#heading(level: 2)[Header one] #label("org0000004")
#heading(level: 2)[Another header] #label("org000000a")
#heading(level: 3)[Wow whats this] #label("org0000007")
#heading(level: 2)[A task] #label("org000000d")
