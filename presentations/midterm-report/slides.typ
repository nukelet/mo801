#import "@preview/bytefield:0.0.7": *

#import "@preview/touying:0.6.1": *
#import themes.university: *
#import "@preview/cetz:0.3.2"
#import "@preview/fletcher:0.5.5" as fletcher: node, edge
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *
#import cosmos.clouds: *
#show: show-theorion

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#show: university-theme.with(
  aspect-ratio: "16-9",
  // align: horizon,
  // config-common(handout: true),
  config-common(frozen-counters: (theorem-counter,)),  // freeze theorem counter for animation
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    logo: emoji.school,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= Animation

== Simple Animation

We can use `#pause` to #pause display something later.

#pause

Just like this.

#meanwhile

Meanwhile, #pause we can also use `#meanwhile` to #pause display other content synchronously.

#speaker-note[
  + This is a speaker note.
  + You won't see it unless you use `config-common(show-notes-on-second-screen: right)`
]


== Complex Animation

At subslide #touying-fn-wrapper((self: none) => str(self.subslide)), we can

use #uncover("2-")[`#uncover` function] for reserving space,

use #only("2-")[`#only` function] for not reserving space,

#alternatives[call `#only` multiple times \u{2717}][use `#alternatives` function #sym.checkmark] for choosing one of the alternatives.


== Callback Style Animation

#slide(
  repeat: 3,
  self => [
    #let (uncover, only, alternatives) = utils.methods(self)

    At subslide #self.subslide, we can

    use #uncover("2-")[`#uncover` function] for reserving space,

    use #only("2-")[`#only` function] for not reserving space,

    #alternatives[call `#only` multiple times \u{2717}][use `#alternatives` function #sym.checkmark] for choosing one of the alternatives.
  ],
)


== Math Equation Animation

Equation with `pause`:

$
  f(x) &= pause x^2 + 2x + 1 \
  &= pause (x + 1)^2 \
$

#meanwhile

Here, #pause we have the expression of $f(x)$.

#pause

By factorizing, we can obtain this result.


== CeTZ Animation

CeTZ Animation in Touying:

#cetz-canvas({
  import cetz.draw: *

  rect((0, 0), (5, 5))

  (pause,)

  rect((0, 0), (1, 1))
  rect((1, 1), (2, 2))
  rect((2, 2), (3, 3))

  (pause,)

  line((0, 0), (2.5, 2.5), name: "line")
})


== Fletcher Animation

Fletcher Animation in Touying:

#fletcher-diagram(
  node-stroke: .1em,
  node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
  spacing: 4em,
  edge((-1, 0), "r", "-|>", `open(path)`, label-pos: 0, label-side: center),
  node((0, 0), `reading`, radius: 2em),
  edge((0, 0), (0, 0), `read()`, "--|>", bend: 130deg),
  pause,
  edge(`read()`, "-|>"),
  node((1, 0), `eof`, radius: 2em),
  pause,
  edge(`close()`, "-|>"),
  node((2, 0), `closed`, radius: 2em, extrude: (-2.5, 0)),
  edge((0, 0), (2, 0), `close()`, "-|>", bend: -40deg),
)


= Theorems

== Prime numbers

#definition[
  A natural number is called a #highlight[_prime number_] if it is greater
  than 1 and cannot be written as the product of two smaller natural numbers.
]
#example[
  The numbers $2$, $3$, and $17$ are prime.
  @cor_largest_prime shows that this list is not exhaustive!
]

#theorem(title: "Euclid")[
  There are infinitely many primes.
]
#pagebreak(weak: true)
#proof[
  Suppose to the contrary that $p_1, p_2, dots, p_n$ is a finite enumeration
  of all primes. Set $P = p_1 p_2 dots p_n$. Since $P + 1$ is not in our list,
  it cannot be prime. Thus, some prime factor $p_j$ divides $P + 1$. Since
  $p_j$ also divides $P$, it must divide the difference $(P + 1) - P = 1$, a
  contradiction.
]

#corollary[
  There is no largest prime number.
] <cor_largest_prime>
#corollary[
  There are infinitely many composite numbers.
]

#theorem[
  There are arbitrarily long stretches of composite numbers.
]

#proof[
  For any $n > 2$, consider $
    n! + 2, quad n! + 3, quad ..., quad n! + n
  $
]


= Others

== Side-by-side

#slide(composer: (1fr, 1fr))[
  First column.
][
  Second column.
]


== Multiple Pages

#lorem(200)


#show: appendix

= Appendix

== Appendix

Please pay attention to the current slide number.

#bytefield(
// Config the header
bitheader(
"bytes",
// adds every multiple of 8 to the header.
0, [start], // number with label
5,
// number without label
12, [#text(14pt, fill: red, "test")],
23, [end_test],
24, [start_break],
36, [Fix], // will not be shown
angle: -50deg, // angle (default: -60deg)
text-size: 8pt, // length (default: global header_font_size or 9pt)
),
// Add data fields (bit, bits, byte, bytes) and notes
// A note always aligns on the same row as the start of the next data field.
note(left)[#text(16pt, fill: blue, "Testing")],
bytes(3,fill: red.lighten(30%))[Test],
note(right)[#set text(9pt); #sym.arrow.l This field \ breaks into 2 rows.],
bytes(2)[Break],
note(left)[#set text(9pt); and continues \ here #sym.arrow],
bits(24,fill: green.lighten(60%))[Fill],
group(right,3)[spanning 3 rows],
bytes(12)[#set text(20pt); *Multi* Row],
note(left, bracket: true)[Flags],
bits(4)[#text(8pt)[reserved]],
flag[#text(8pt)[SYN]],
flag(fill: orange.lighten(60%))[#text(8pt)[ACK]],
flag[#text(8pt)[BOB]],
bits(25, fill: purple.lighten(60%))[Padding],
// padding(fill: purple.lighten(40%))[Padding],
bytes(2)[Next],
bytes(8, fill: yellow.lighten(60%))[Multi break],
note(right)[#emoji.checkmark Finish],
bytes(2)[_End_],
)
