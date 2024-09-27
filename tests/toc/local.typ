#set text(lang: "en")
#set heading(numbering: "1.")
#heading(level: 1)[A] #label("org0000006")
#heading(level: 2)[A1] #label("org0000003")
#heading(level: 3)[A11] #label("org0000000")
#heading(level: 1)[B] #label("org000001e")
#heading(level: 2)[B1] #label("org000001b")
#context {
  let before = query(
    selector(heading).before(here(), inclusive: true),
  )
  let elm = before.pop()
  let after_elements = query(
    heading.where(outlined: true).after(here(), inclusive: true),
  )
  let next_maybe = after_elements.find(it => it.level <= elm.level)
  let next = if next_maybe == none {
    after_elements.pop()
  } else {
    next_maybe
  }
  outline(
    title: none,
    depth: 4,
    target: heading.where(outlined: true).after(
      elm.location(),
      inclusive: false,
    ).and(
      heading.where(outlined: true).before(
        next.location(),
        inclusive: next_maybe == none,
      ),
    ),
  )
}
Expecting a TOC with the entries B11, B111, B12, B121, B13, B131.
#heading(level: 3)[B11] #label("org000000c")
#heading(level: 4, outlined: false, numbering: none)[B111] #label("org0000009")
#heading(level: 3)[B12] #label("org0000012")
#heading(level: 4, outlined: false, numbering: none)[B121] #label("org000000f")
#heading(level: 3)[B13] #label("org0000018")
#heading(level: 4, outlined: false, numbering: none)[B131] #label("org0000015")
#heading(level: 1)[B2] #label("org0000036")
#heading(level: 2)[B1] #label("org0000033")
#context {
  let before = query(
    selector(heading).before(here(), inclusive: true),
  )
  let elm = before.pop()
  let after_elements = query(
    heading.where(outlined: true).after(here(), inclusive: true),
  )
  let next_maybe = after_elements.find(it => it.level <= elm.level)
  let next = if next_maybe == none {
    after_elements.pop()
  } else {
    next_maybe
  }
  outline(
    title: none,
    depth: 3,
    target: heading.where(outlined: true).after(
      elm.location(),
      inclusive: false,
    ).and(
      heading.where(outlined: true).before(
        next.location(),
        inclusive: next_maybe == none,
      ),
    ),
  )
}
Expecting a TOC with the entries B21, B22, B23.
#heading(level: 3)[B21] #label("org0000024")
#heading(level: 4, outlined: false, numbering: none)[B211] #label("org0000021")
#heading(level: 3)[B22] #label("org000002a")
#heading(level: 4, outlined: false, numbering: none)[B221] #label("org0000027")
#heading(level: 3)[B23] #label("org0000030")
#heading(level: 4, outlined: false, numbering: none)[B231] #label("org000002d")
#heading(level: 1)[C] #label("org0000039")
