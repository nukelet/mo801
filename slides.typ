#import "@preview/polylux:0.4.0": *
#import "@preview/metropolis-polylux:0.1.0" as metropolis
#import metropolis: new-section, focus

#show: metropolis.setup

#let my-stroke = stroke(
  thickness: 2pt,
  paint: blue.lighten(50%),
  cap: "round",
)

#set page(
  header: box(stroke: (bottom: my-stroke), inset: 8pt)[
    #set text(size: .6em)
    #set align(horizon)
    // #box(image("../assets/polylux-logo.svg", height: 2em))
    #h(1fr)
    #toolbox.current-section
  ],
  footer: [
    #set text(size: .6em)
    #set align(horizon)
        *GVSoC: A Highly Configurable, Fast and Accurate Full-Platform Simulator for RISC-V based IoT processors*
        #h(1fr) #toolbox.slide-number
  ],
  margin: 3em
)

#slide[
  #set page(header: none, footer: none, margin: 3em)

 
  #text(size: 1.3em)[
    #set align(center)
    *GVSoC: A Highly Configurable, Fast and Accurate Full-Platform Simulator for RISC-V based IoT processors*
  ]

  #align(center)[
    Paper review
  ]

  #metropolis.divider
  
  #set text(size: .8em, weight: "light")
  Vinicius Peixoto

  MO801 - Tópicos em Arquitetura de Computadores

  Sep 17th 2025
]

#slide[
  #set page(header: none)
  == Agenda

  #metropolis.outline
]

#new-section("Introduction")
#slide[
  == Architecture-level simulation

  - Different levels of abstraction

  - Tradeoff between accuracy vs. simulation speed

  - *Functional simulators*
    - Only simulate behavior (no uarch nuances)
    - Typically very fast, often inaccurate
    - Example: Spike
]

#slide[
  == Architecture-level simulation
  - *Timing simulators*
    - Model the uarch of the target (cache hierarchy, pipelines, branch pred., ... )
    - Much slower than functional simulation
    - *Cycle-accurate*: accurate cycle-by-cycle simulation
      - Example: Verilator (System Verilog $->$ C++ executable)
    - *Instruction-level*: instruction-by-instruction simulation
      - Faster than cycle-accurate
      - Example: Gem5's O3CPU model
] 

#slide[
  == Architecture-level simulation
  - *Timing simulators*
    - *Event-driven*: _events_ instead of _cycles_
      - _event_ = change of state in the system occurring at a certain point in time
      - Schedule events in a queue based on their _latency_
      - Jump directly to time of occurrence of next event
      - Skipping idle cycles $->$ consistent savings in simulation time
      - Examples: SystemC + Transaction Level Modeling (TLM), RISC-V-TLM
] 

#slide[
  == State of the art

  - Established timing simulation solutions lack flexibility (e.g. testing SoCs)
    - Cycle-accurate sims: slow, adding peripherals is cumbersome
    - Timing sims: faster, but still difficult to extend
  - *Author's proposal*: a highly flexible, event-driven simulator targeted at
    _full system emulation_
]

#new-section("Target architecture")

#slide[
  == PULP
  - *P*\arallel *U*\ltra-*L*\ow *P*\ower platform
    - Open-source heterogeneous computing platform
    - RISC-V MCU (PULP SoC) + parallel programmable accelerator (PULP CL) + peripherals
    - Separate clock domains for easier workload tuning
]

#slide[
  == PULP SoC

  - FC (_Fabric Controller_): RISC-V processor
    - Manages the peripheral subsystem
    - Offloads compute-intensive tasks to the accelerator
    - Equipped with 256KiB - 2MiB of SRAM
      - Stores the code and application data
      - Paper calls it _L2_ (?)
]

#slide[
  == PULP SoC

  - FC (_Fabric Controller_): RISC-V processor
    - Comprehensive set of peripherals (JTAG, SPI, I2C, I2S, GPIOs, ...)
      - I/O DMA (called uDMA) for L2 memory $<->$ peripheral data transfer
    - HyperBUS DDR interface
      - 8-bit high-speed bus for memory expansion (external DRAM, flash, ...)
]

#slide[
  == PULP PL
  - a
]

#slide[
  #figure(
    image("images/pulp-soc-diagram.png", width: 115%),
    caption: [
      The PULP SoC architecture.
    ],
  )
]

#new-section("Criticism")
#slide[
  - Low memory even for IoT devices, unfeasible for testing intensive workloads
]

#new-section[My first section]
#slide[
  = The Fundamental Theorem of Calculus

  For $f = (dif F) / (dif x)$ we _know_ that
  $
    integral_a^b f(x) dif x = F(b) - F(a)
  $

  See `https://en.wikipedia.org/wiki/Fundamental_theorem_of_calculus`
]

#slide[
  slide without a title
]

#new-section[My second section]

#slide[
  = Heron algorithm

  ```julia
  function heron(x)
      r = x
      while abs(r^2 - x) > eps()
          r = (r + x / r) / 2
      end
      return r
  end

  @test heron(42) ≈ sqrt(42)
  ```
]

#slide[
  #show: focus
  Something very important
]
