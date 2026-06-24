# Lightweight RV32I-Based Dot-Product Accelerator for Edge-AI FPGA Systems

This repository contains the Verilog RTL design, testbench, result data, and figures for a lightweight RV32I-controlled memory-mapped dot-product accelerator implemented on a Xilinx Artix-7 FPGA.

## Overview

The proposed architecture integrates an RV32I processor core with a memory-mapped sequential dot-product accelerator. The accelerator supports software-selectable vector-length execution through a memory-mapped `VECTOR_LENGTH` register. The hardware is parameterized for a maximum vector length of 16 elements.

## Features

- RV32I-controlled memory-mapped accelerator
- Sequential dot-product MAC datapath
- Single DSP48E1-based multiply-accumulate operation
- Software-selectable vector length: N = 4, N = 8, N = 16
- Result and cycle-count readback through memory-mapped registers
- Implemented using Verilog RTL
- Evaluated using Vivado 2025.2 on Xilinx Artix-7

## FPGA Setup

| Parameter | Value |
|---|---|
| HDL | Verilog |
| Tool | Vivado 2025.2 |
| FPGA family | Xilinx Artix-7 |
| Device | xc7a35tcpg236-1 |
| Top module | rv32i_mm_ai_core |
| Testbench | tb_rv32i_mm_ai_core |
| Clock period | 20 ns |
| Frequency | 50 MHz |
| Maximum vector length | 16 |
| Accelerator type | Sequential dot-product MAC |
| DSP usage | 1 DSP48E1 |

## Repository Structure

```text
rtl/       Verilog RTL source files
tb/        Verilog testbench files
results/   Functional and FPGA implementation result summaries
figures/   Generated result figures
docs/      Architecture diagrams and supporting documentation

Functional Verification
Vector length	Expected result	Hardware result	Execution cycles	Status
4	70	70	4	Passed
8	36	36	8	Passed
16	16	16	16	Passed

Notes

The reported power values are Vivado routed-stage vectorless estimates and are not physical board-level power measurements.

Author

Adithya C
Department of Electronics and Communication Engineering
BMS College of Engineering, Bengaluru, India