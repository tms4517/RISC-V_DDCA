# Single cycle

A 32-bit RISC-V architecture will be implemented.

The microarchitecture can be divided into two interacting parts:
  1. Data-path: Contains structures such as memories, registers, ALUs, and
     multiplexers.
  2. Control-unit: Receives the current instruction from the data-path and produces
     multiplexer select, register enable, and memory write signals to control the
     operation of the data-path.

## State Elements

As a start, the hardware containing the state elements will be designed. These
elements include the memories and the architectural state (the program counter
and registers). Then, to compute the new state based on the current state blocks
of combinational logic between the state elements will be added.
