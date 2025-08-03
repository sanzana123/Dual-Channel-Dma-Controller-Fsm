# Dual-Channel DMA Controller (Verilog)
This project implements a dual-channel Direct Memory Access (DMA) controller using Verilog. Each channel can independently read data from a source memory and write it to a destination address. The system uses Finite State Machines (FSMs) to manage transfers and signal completion.

Features
- Two independent DMA channels (channel1, channel2)
- 8-bit addressing with 16-bit data transfer
- Configurable source and destination base addresses
- Start and Done control signals per channel
- FSM-based transfer control
- Written in Verilog and tested using JDoodle Verilog Simulator

# Project Structure
### DMA_2ch Module
Handles both channels in parallel with shared inputs (clk, reset) and separate control signals and data buses.
### Testbench (commented in source file)
Simulates memory, verifies data integrity post-transfer, and includes dummy memory initialization and read/write logic.

# How It Works
- Each channel proceeds through the following states:
- IDLE – Wait for the start signal.
- READ – Load source address and prepare read.
- WRITE – Write data to the destination address.
- DONE – Signal completion and reset to idle.

Transfers occur until the configured length is reached.

# Simulation Example
Memory is initialized with test values at source locations.
After both DMA channels complete, memory at the destination addresses is verified.
The testbench prints memory before and after the operation.

# Running the Project
To run this in JDoodle:
- Paste the Verilog module and testbench in JDoodle Verilog IDE.
- Uncomment the testbench section.
- Run the simulation and observe the memory transfer in the console output
