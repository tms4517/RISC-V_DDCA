# Multi-cycle introduction

## Single-Cycle vs Multi-Cycle

In a single-cycle processor, each instruction takes one clock cycle. So, the
maximum clock frequency is determined by the most time consuming instruction.
In the implementation https://github.com/tms4517/RISC-V_DDCA/tree/main/single-cycle,
it is the lw instruction since the critical path involves an ALU operation,
memory access and register file access. The path is shown below.

Pic

The single-cycle processor has the following limitations:
1. It requires separate memories for instructions and data, whereas most
processors have only a single external memory holding both instructions and data.
2. It requires a clock cycle long enough to support the slowest instruction (lw)
even though most instructions could be faster.
3. It requires three adders (one in the ALU and two for the PC logic).

The multi-cycle processor addresses these weaknesses by breaking an instruction
into multiple shorter steps. The memory, ALU, and register file have the longest
delays, so to keep the delay for each short step approximately equal, the
processor can use only one of those units in each step. The processor uses a
single memory because the instruction is read in one step and data is read or
written in a later step. And the processor needs only one adder, which is reused
for different purposes on different steps. Various instructions use different
numbers of steps, so simpler instructions can complete faster than more complex
ones.

## This repository

In this sub-repository, as a start, the single-cycle RTL has been copied over
and modifications to convert the single-cycle processor to a multi-cycle
processor have been made. They include adding registers to hold intermediate
results between the steps and designing an fsm so that the controller can
produces different signals on each step,

The remainder of this text explains the modifications made.
