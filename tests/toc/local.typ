#set text(lang: "en")
#set heading(numbering: "1.")
#heading(level: 1)[A] <org0000006>
#heading(level: 2)[A1] <org0000003>
#heading(level: 3)[A11] <org0000000>
#heading(level: 1)[B] <org000001e>
#heading(level: 2)[B1] <org000001b>
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
#heading(level: 3)[B11] <org000000c>
#heading(level: 4, outlined: false, numbering: none)[B111] <org0000009>
#heading(level: 3)[B12] <org0000012>
#heading(level: 4, outlined: false, numbering: none)[B121] <org000000f>
#heading(level: 3)[B13] <org0000018>
#heading(level: 4, outlined: false, numbering: none)[B131] <org0000015>
#heading(level: 1)[B2] <org0000036>
#heading(level: 2)[B1] <org0000033>
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
#heading(level: 3)[B21] <org0000024>
#heading(level: 4, outlined: false, numbering: none)[B211] <org0000021>
#heading(level: 3)[B22] <org000002a>
#heading(level: 4, outlined: false, numbering: none)[B221] <org0000027>
#heading(level: 3)[B23] <org0000030>
#heading(level: 4, outlined: false, numbering: none)[B231] <org000002d>
#heading(level: 1)[C] <org0000039>
