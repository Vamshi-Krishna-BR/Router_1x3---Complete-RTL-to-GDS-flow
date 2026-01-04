# 1×3 Packet Router – RTL to GDSII Implementation

## Overview
This project implements a packet-based 1×3 router in Verilog that routes incoming packets to one of three output ports based on header information. The design supports packetized data transfer with flow control, buffering, and error detection, and is implemented through a complete RTL-to-GDSII physical design flow.

## Architecture
The router processes packets consisting of a header, payload, and parity byte.  
The header contains destination and payload length information, which is decoded by the control logic to select the appropriate output FIFO.

The design is modular and includes:
- FSM for packet sequencing and control
- Register block for header, payload, and parity handling
- Synchronizer logic for write enable generation and soft reset
- Three output FIFOs for independent buffering and backpressure handling

## Key Features
- Packet-based routing to 1 of 3 output ports
- FSM-controlled header decoding and payload sequencing
- Parameterized FIFO design with full/empty detection
- Parity generation and checking for error detection
- Support for back-to-back packets with variable payload lengths
- Soft reset mechanism for fault recovery

## Design Flow
- RTL design in Verilog
- Functional verification using waveform-based simulation
- Synthesis with timing constraints
- Floorplanning, placement, CTS, and routing
- Static Timing Analysis and timing closure
- Final GDSII generation

## Tools Used
- Verilog
- Xilinx ISE
- Synopsys Fusion Compiler
- PrimeTime
- TCL scripting
- Linux
