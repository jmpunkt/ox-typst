#set text(lang: "en")
#set heading(numbering: "1.")
= A <org0000006>
== A1 <org0000003>
=== A11 <org0000000>
= B <org000001e>
== B1 <org000001b>
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
=== B11 <org000000c>
==== B111 <org0000009>
=== B12 <org0000012>
==== B121 <org000000f>
=== B13 <org0000018>
==== B131 <org0000015>
= B2 <org0000036>
== B1 <org0000033>
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
=== B21 <org0000024>
==== B211 <org0000021>
=== B22 <org000002a>
==== B221 <org0000027>
=== B23 <org0000030>
==== B231 <org000002d>
= C <org0000039>
