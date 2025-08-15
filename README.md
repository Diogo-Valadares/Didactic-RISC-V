# Didactic-RISC-V

This project is part of a monograph focused on transforming the legacy RISC I architecture into a modern educational tool. The goal is to recreate RISC I, enhance it with features found in contemporary architectures, and evolve it into a design that aligns with the RISC-V specification.

![Didactic-RISC-V Architecture](https://github.com/user-attachments/assets/c3bb8eed-a5ef-40f1-b8df-c6eda5cc1376)

## Overview

The project aims to faithfully reconstruct the original RISC I architecture and then extend it for didactic purposes. This repository contains both the RISC I recreation and the enhanced DRISC-V architecture, allowing side-by-side comparison and analysis.

The RISC I implementation is inspired by the works of [James B. Peek](https://www2.eecs.berkeley.edu/Pubs/TechRpts/1983/CSD-83-135.pdf) and [Manolis G. H. Katevenis](https://archive.org/details/reducedinstructi0000kate/mode/2up).  
While not a perfect replica—due to simulation constraints and limited documentation—it successfully reproduces the full RISC I instruction set and retains the original structural design.

To support simulation and experimentation, a custom assembler written in C# has been developed. It translates assembly code into machine-readable instructions compatible with the simulation models, with a focus on transparency and debugging.

## Features

- **Logisim Simulations**  
  Both RISC I and DRISC-V architectures are available as interactive Logisim models.

- **SystemVerilog Implementation**  
  DRISC-V includes a SystemVerilog version for high-performance simulation and testing.

- **Custom C# Assembler**  
  A dedicated assembler that converts assembly language into executable machine code, designed to illustrate the assembly process and assist in system development and debugging.

- **Educational Focus**  
  Built as a comprehensive teaching tool for learning computer architecture, ideal for students, educators, and enthusiasts.
