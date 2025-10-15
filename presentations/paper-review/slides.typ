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
  == PULP CL (compute cluster)
  - Many RISC-V cores sharing multiple banks of *TCDM* (*T*\ightly *C*\oupled *D*\ata *M*\emory)
  - TCDM banks can be accessed in a _single clock cycle_ due to an intricate low-latency logarithmic interconnect
  - 2-level instruction cache: private L1 cache (512B - 1KiB) and L1.5 cache (4-8KiB) that refills from L2 memory
  - L1 $<->$ L2 data transfers through multi-channel DMA
]

#slide[
  == PULP CL (compute cluster)
  - Hardware sync unit controls common sync operations such as barriers, thread dispatching, etc.
  - Support for energy-efficient DSP extensions (Xpulp)
  - Standard interface (Hardware Processing Engines - HWPE) for connecting custom HW accelerators to the PULP CL domain + L1 memory
]

#slide[
  #figure(
    image("images/pulp-soc-diagram.png", width: 115%),
    caption: [
      The PULP SoC architecture.
    ],
  )
]

#new-section("GVSoC architecture")

#slide[
  == Overview
  - Event-driven simulator targeting the PULP architecture
  - Models the uarch + common building blocks (cores, memory, peripherals, interconnects, ...)
  - Designed to support easy testing of arch + uarch + I/O functionality side-by-side
  - Offers debug tools and HW counters for early-stage perf evaluation
]

#slide[
  == Structure
  - Comprised of three main components:
    - C++ models: simulate the behavior components (cores, memories, DMA, peripherals, ...)
    - JSON configs: specify architecture params (core counts, interconnect bw/latency, ...)
    - Python generators: orchestrate the instantiation of components
    - Compile C++ models first $->$ quick prototyping of different system configurations without the need to rebuild the models
]

#slide[
  #figure(
    image("images/gvsoc-overview.png", width: 85%),
    caption: [
      Overview of the main components of GVSoC.
    ],
  )
]

#slide[
  == Structure
  - GVSoC components interact through *message-passing*
  - Components receive *requests* and can choose to handle them by themselves or forward them to another component
  - Tries to simulate latency accurately (e.g. when requests go through multiple components)
]

#slide[
  #figure(
    image("images/gvsoc-request.png", width: 85%),
    caption: [
      Example of a GVSoC request lifecycle.
    ],
  )
]

#slide[
  == Time modeling
  - A *global time engine* manages the overall time (at picosecond scale)
  - *Clock engines* model individual clock sources
    - Forward monotone counters associated with a circular event queue
    - Each engine defines a *window* $T_w$; every event that will happen within $T_w$ cycles in included in the circular queue
    - Simultaneous events are executed sequentially within the same cycle
]

#slide[
  == Time modeling
  - *Clock engines* model individual clock sources
    - Events outside of the $T_w$ window are sent to a separate ordered queue (called the *delayed event queue*)
    - Whenever a lap around the circular event queue is completed, events are read from the delayed event queue
]

#slide[
  #figure(
    image("images/gvsoc-event-queue.png", width: 85%),
    caption: [
      Overview of the GVSoC event queue.
    ],
  )
]

#slide[
  == Time modeling
  - All componentes are related to a *clock domain*, i.e. a tree of clock sources (with associated clock engines)
  - Mechanisms for synchronizing requests across clock domains (*stubs*)
]

#slide[
  #figure(
    image("images/gvsoc-time-engine.png", width: 100%),
    caption: [
      Overview of the GVSoC time engine.
    ],
  )
]

#slide[
  == Hardware perf counters
  - Models performance metrics for real hardware
  - Full tracing capabilities for events in GVSoC
  #figure(
    image("images/gvsoc-hw-perfcounters.png", width: 40%),
    // caption: [
    //   Overview of the GVSoC time engine.
    // ],
  )
]

#new-section("Use cases and results")
#slide[
  The author goes over 3 use case studies:
  - Execution of a full MobileNetV1 model
  - Running commonly-used DSP kernels using the PULP CL
  - Integrating a custom convolution hw accelerator in PULP CL
]

#slide[
  == MobileNetV1
  - Emulated both on GVSoC and on a Xilinx ZCU102 FPGA
  - Uses PULP CL cores in a SIMD fashion
  - Compares simulation error between FPGA and GVSoC
]

#slide[
  #figure(
    image("images/gvsoc-mobilenetv1.png", width: 115%),
    // caption: [
    //   Overview of the GVSoC time engine.
    // ],
  )
]

#slide[
  == DSP kernels + custom convolution accelerator
  - Emulated only on GVSoC
  - Explores performance scalability in response to number of cores and TCDM banks
]

#slide[
  #figure(
    image("images/gvsoc-remaining.png", width: 70%),
    // caption: [
    //   Overview of the GVSoC time engine.
    // ],
  )
]

#new-section("Comparison with other tools and conclusion")
#slide[
  #figure(
    image("images/gvsoc-comparison.png", width: 115%),
    // caption: [
    //   Overview of the GVSoC time engine.
    // ],
  )
]

#slide[
  == Conclusion
  - GVSoC offers comparable performance to other event-driven timing simulators
  - Lots of flexibility for prototyping and doing early validation on SoCs
  - Shows potential for simulating IoT/low-power devices using the PULP architecture
]

#new-section("Discussion of the paper")
#slide[
  == Discussion
  - The good:
    - Very well-written, lots of content, informative discussion of the internals of GVSoC's architecture
    - The GVSoC framework itself is open source and available on GitHub
    - Provides a useful tool for other researchers to prototype their platforms on
    - Presents a good performance comparison with other available simulation tools
]

#slide[
  == Discussion
  - The bad:
    - Very rushed discussion of the use cases and testing methodology
      - e.g. how exactly are they leveraging the PULP CL for accelerating MobileNetV1?
    - Would like to see more details about the logarithmic interconnect bus
    - Only applicable to the simulation of resource-constrained systems (and especifically the ones using the PULP architecture)
]

#slide[
  == Discussion
  - The ugly
    - GVSoC's documentation is lacking
    - No source code for reproducing the tests in the paper
    - Most examples in GVSoC's documentation use the GAP9 core, which is *closed-source* and thus most examples in the docs are rendered useless
      - Some important features (such as GDB debugging) only work on this proprietary core
]
