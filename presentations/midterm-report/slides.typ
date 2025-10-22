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

#set text(font: "Fira Sans")
#show: university-theme.with(
  aspect-ratio: "16-9",
  // align: horizon,
  // config-common(handout: true),
  config-common(frozen-counters: (theorem-counter,)),  // freeze theorem counter for animation
  config-info(
    title: [Midterm report],
    subtitle: [MO801 - Topics in Hardware and Computer Architecture],
    author: [Vinicius Peixoto],
    institution: [Institute of Computing, UNICAMP],
    date: "October 2025",
  ),
)

// #set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

#slide(
  align(center, text(size: 50pt, "Code available at:\ngithub.com/nukelet/mo801"))
)

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= Lab 01: Spike

== Methodology

Different implementations of matmul:

- naive (outer $->$ inner: $M$, $N$, $K$)
- alt (outer $->$ inner: $N$, $M$, $K$)
- transpose (scalar product of rows by rows)
- vector (vectorized, modified `fmadd.q` instruction)

Compromises:

- No i-cache (small code size)
- No L2 cache (for simplicity)
- $M = N = 256$ ($512$ took way too long to run)

---

#{
  show table.cell: set text(size: 20pt)
  figure(
    table(
      columns: (auto, auto, auto, auto),
      align: center,
      table.header(
        [*`sets`*], [*`ways`*], [*`bsize`*], [*`total size`*]
      ),
      [256], [1], [32], [8 KiB],
      [128], [2], [32], [8 KiB],
      [64], [4], [32], [8 KiB],
      [64], [2], [64], [8 KiB],
      [128], [2], [64], [16 KiB],
      [256], [2], [64], [32 KiB],
      [128], [2], [128], [32 KiB],
      [16384], [1], [32], [512 KiB],
      [8192], [2], [32], [512 KiB],
      [4096], [4], [32], [512 KiB],
      [8192], [2], [64], [1024 KiB],
      [16384], [2], [64], [2048 KiB],
      [8192], [2], [128], [2048 KiB],
    ),
    caption: [Cache dimensions used in the experiment.],
  )
}

---

== Hello world

#figure(
  image("./images/q1-icache.png")
)

---

#figure(
  image("./images/q1-dcache.png")
)

---

== Matmul

#figure(
  image("./images/q2-naive-dcache.png")
)

---

- Based on the results: choice of a 64 KiB i-cache (`256:4:64`)

- Counting instructions:
  - `riscv64-unknown-elf-objdump --disassemble=<symbol-name>`
  - `spike -g ...`
  - Parse histogram, sum counts from addresses within the function

---

- Implementation of vectorized `matmul`
  - GCC 14 and 15 do not yet support the Q extension
  - `riscv64-unknown-elf-as` does though
  - Workaround: manually implement `asm` stub, export it as symbol, call it from regular code
- Several hurdles:
  - `pk` needs to be compiled with support for the `F`/`D`/`Q` extensions
  - Need to run `spike` with the `--isa=rv64gqc` flag (otherwise `pk` falls back to softfloat and traps floating point instructions)
  - Need to take care with 128-bit alignment lest we get faults (`-O0` makes the program crash due to this)

---

  ```asm
  .global fmaddq_stub
  fmaddq_stub:
      flq fa0, 0(a1)
      flq fa1, 0(a2)
      flq fa2, 0(a3)
      fmadd.q fa0, fa0, fa1, fa2
      fsq fa0, 0(a0)
      ret
  ```

  ```C
  void fmaddq_stub(float result[4], float a[4], float b[4], float c[4]);
  ```

---


#figure(
  image("./images/q2-inst-count.png")
)

---

#figure(
  image("./images/q2-miss-rate.png")
)

---

== Takeaways

- `naive` and `alt` perform pretty bad cache locality-wise, `transpose` already much better
- The vectorized variant reduces the instruction count by ~80% (very noticeable speedup in execution on Spike)
  - Seems to be worth using even at higher cost in latency/power consumption
- No significant improvement from `-O2` to `-O3` (but definitely from `-O0` to `O2`)

---

= Lab 02: QEMU

---

- R-type:
#{
  set text(16pt);
  bytefield(
    msb: left,
    bitheader("bounds"),
    bits(7)[funct7],
    bits(5)[rs2],
    bits(5)[rs1],
    bits(3)[funct3],
    bits(5)[rd],
    bits(7)[opcode],
  )
}

- I-type:
#{
  set text(16pt);
  bytefield(
    msb: left,
    bitheader("bounds"),
    bits(11)[imm],
    bits(5)[rs1],
    bits(3)[funct3],
    bits(5)[rd],
    bits(7)[opcode],
  )
}

---

- `bitrev`:
#{
  set text(16pt);
  bytefield(
    msb: left,
    bitheader("bounds"),
    bits(11)[`00000000000`],
    bits(5)[rs1],
    bits(3)[`000`],
    bits(5)[rd],
    bits(7)[`1111111`],
  )
}

- `cclz`:
#{
  set text(16pt);
  bytefield(
    msb: left,
    bitheader("bounds"),
    bits(11)[`00000000000`],
    bits(5)[rs1],
    bits(3)[`001`],
    bits(5)[rd],
    bits(7)[`1111111`],
  )
}

- `cctz`:
#{
  set text(16pt);
  bytefield(
    msb: left,
    bitheader("bounds"),
    bits(11)[`00000000000`],
    bits(5)[rs1],
    bits(3)[`010`],
    bits(5)[rd],
    bits(7)[`1111111`],
  )
}

---

- `multmod`:
#{
  set text(16pt);
  bytefield(
    msb: left,
    bitheader("bounds"),
    bits(7)[`1111111`],
    bits(5)[rs2],
    bits(5)[rs1],
    bits(3)[`110`],
    bits(5)[rd],
    bits(7)[`0110011`],
  )
}

---

#{
  set text(20pt)
  ```C
  static bool trans_multmod(DisasContext *ctx, arg_multmod *a)
  {
      TCGv rs1, rs2, rd;

      rs1 = get_gpr(ctx, a->rs1, EXT_NONE);
      rs2 = get_gpr(ctx, a->rs2, EXT_NONE);
      rd = get_gpr(ctx, a->rd, EXT_NONE);

      tcg_gen_mul_tl(rd, rd, rs1);
      tcg_gen_rem_tl(rd, rd, rs2);

      gen_set_gpr(ctx, a->rd, rd);

      return true;
  }
  ```
}

---

= Lab 03: gem5

---

== Overview

- gem5 is a functional, event driven simulator for computer systems
- capable of emulating several arches (x86, arm64, riscv, ...)
- modular, composable, extensible

== Lessons learned

- Decided to build locally since I run Ubuntu 25.04 on my machine; ran into several build issues that I fixed along the way
- Was able to run through the best part of the "Learning gem5" tutorial
  - #link("https://www.gem5.org/documentation/learning_gem5/introduction/")
- Was able to set up and reproduce the tests in the SSCAD 2024 repo from LSC
- Struggling to grasp the details but understood the general workflow for extending the ISA and configuring uarch details within gem5

---

= Final project proposal

---

== Proposal

- New extension currently under development: Supervisor Domain Access Protection
- #link("https://github.com/riscv/riscv-smmtt")
- Aims to enable confidential computing use cases on RISC-V
- Defines a data structure called `MPT` (Memory Protection Table) that configures and enforces read/write permissions to physical memory addresses (or device-mapped regions) based on `SDIDs` (Supervisor Domain Identifiers)

---

- *Proposal*: implement at least a subset of the following extensions in Spike
  - `Smsdid`: interface to program the active supervisor domain under which a hart is operating
  - `Smmpt`: extension to set the access permissions for a memory region or page associated with a supervisor domain
- *Objective*: develop a proof-of-concept of the extensions, showing effective resource isolation between different `SDIDs`
