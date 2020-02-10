# RISC-V
Bare Metal RISC-V core employing 32 &amp; 64-bit
It is a parametrized core which contains only the basic components required in the core startup and it has following parts:
* Counter
* IMEM (Instruction Memory)
* RegFile (Register File)
* ALU
* DMEM (Data Memory)
* ImmGen (Immediate Generator)
* Forwarding
* Assertion
* Branch always taken
* Piplining
* All Hazards taken account for

I've generalized it so that you can  check the functionality of 32 and 64 bit just by changing parameter in the main module i.e. ***riscv.v***

## FPGA Board ##
The FPGA Board used was ***Altera DE1 Cyclone-II*** and the core can be easily synthesized for it. Also, IMEM can be initialized by manually creating the rom or it can be initialzed by using rom_one_port module from the MegaWizard Plugin Manager
