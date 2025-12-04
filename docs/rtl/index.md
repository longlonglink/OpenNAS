---
title: Firmware Implementation
---

# OpenNAS Firmware Implementation Guide

This document provides detailed information on implementing the FPGA firmware for the OpenNAS project, including core features such as TCP Offload Engine (TOE), storage implementation, network acceleration, and energy efficiency optimization.

## Overview

OpenNAS firmware is implemented on Xilinx Zynq-7000 series FPGA (XC7Z035) using **Scala with SpinalHDL mixed with Verilog** to write HDL code. This hybrid design approach combines SpinalHDL's type safety and high-level abstraction capabilities with Verilog's flexibility and compatibility, making the code more robust and maintainable. The firmware design follows modular and extensible principles, with all code fully open source.

### Why SpinalHDL?

- **Type Safety**: Scala's strong type system can catch many errors at compile time
- **High-Level Abstraction**: SpinalHDL provides higher-level hardware description abstractions, reducing code volume
- **Reusability**: Better modularity and code reuse
- **Mixed Design**: Seamless integration with existing Verilog IP cores

## Development Environment

### Toolchain

- **Primary Tool**: Xilinx Vivado (current version)
- **Future Plans**: Support for open-source toolchains (Yosys + nextpnr)
- **Simulation Tools**: XSim (Vivado built-in), Verilator (open-source simulator)
- **Version Control**: Git
- **Build Tool**: SBT (Scala Build Tool)

### Environment Setup

```bash
# Install Scala and SBT
# Install Vivado
# Configure environment variables
export VIVADO_HOME=/path/to/vivado
export PATH=$PATH:$VIVADO_HOME/bin
```

## TCP Offload Engine (TOE) Implementation

### Architecture Design

The TOE module offloads the TCP/IP protocol stack from CPU to FPGA hardware, achieving high-performance network processing. The module adopts a pipeline design, supporting 10Gbps line-rate processing.

#### Module Division

1. **MAC Layer Interface**
   - 10Gbps Ethernet MAC interface
   - Supports SFP+ optical modules
   - Auto-negotiation and link management
   - Supports 4 independent network interfaces

2. **IP Layer Processing**
   - IPv4/IPv6 packet parsing
   - IP routing and forwarding
   - Fragmentation and reassembly
   - Supports multicast and broadcast

3. **TCP Layer Processing**
   - Connection establishment and teardown (three-way handshake, four-way handshake)
   - Sequence number and acknowledgment number management
   - Flow control and congestion control
   - Retransmission mechanism
   - Supports large numbers of concurrent connections (up to 64K)

4. **Application Layer Interface**
   - AXI4 interface with ARM CPU: For control plane communication and configuration
   - AXI-Stream interface with NVMe module: For data plane zero-copy transfer
   - Zero-copy data transfer: Data transfers directly between network and storage, bypassing CPU
   - Event notification mechanism: Notifies CPU through interrupts or polling

### Implementation Details

#### 1. Interface Description

The TOE module provides the following main interfaces:

**AXI4 Interface with ARM CPU**:
- **AXI4-Lite Control Interface**: For configuring TOE parameters, querying connection status, etc.
- **AXI4 Data Interface**: For transferring small amounts of control data
- **Interrupt Interface**: For event notification (e.g., new connection established, connection closed, etc.)

**AXI-Stream Interface with NVMe Module**:
- **Receive Data Stream (RX)**: Data received from network directly transferred to NVMe module via AXI-Stream
- **Transmit Data Stream (TX)**: Data read from NVMe module directly transferred to network via AXI-Stream
- **Flow Control Signals**: Standard AXI-Stream signals such as `tready`, `tvalid`, `tlast`
- **Data Width**: 512-bit, matching NVMe data width

**Network Interface**:
- **4× 10Gbps SFP+ Interfaces**: Supports optical modules and direct-attach copper cables
- **MAC Layer Interface**: Interface with Ethernet PHY

**Internal Interfaces**:
- **Connection Table Interface**: For lookup and management of TCP connections
- **Buffer Interface**: For temporary storage of packets

#### 2. TCP State Machine



### Performance Optimization

1. **Pipeline Design**: Divide packet processing into multiple pipeline stages to improve throughput
2. **Parallel Processing**: Support multiple packets processing simultaneously, fully utilizing FPGA parallelism
3. **Zero-Copy**: Data transfers directly between FPGA and memory, bypassing CPU, reducing latency
4. **Hardware Acceleration**: TCP checksum, IP checksum calculated in hardware

## Storage Implementation

### NVMe Controller

#### PCIe Soft Core Implementation

The PCIe soft core uses Xilinx GT (Gigabit Transceiver) to implement PCIe 3.0 x4 interface. This implementation includes:

- **PCIe Configuration Space**: Implements standard PCIe configuration registers
- **TLP (Transaction Layer Packet) Processing**: Handles PCIe transaction layer packets
- **Link Training**: Auto-negotiates link speed and width
- **Error Handling**: CRC checking, retransmission mechanisms, etc.

The PCIe soft core connects with the NVMe controller through AXI4 interface, achieving efficient data transfer.

#### NVMe Queue Management

**Multi-Queue Concurrency** is one of the core features of NVMe. OpenNAS implements complete NVMe multi-queue support:

**Queue Architecture**:
- **Admin Queue**: 1 submission queue (SQ) and 1 completion queue (CQ)
- **I/O Queues**: Supports up to 65535 I/O queue pairs (each queue pair contains 1 SQ and 1 CQ)
- **Queue Depth**: Each queue supports up to 65536 entries

**Concurrent Processing**:
- **Parallel Queue Processing**: Multiple I/O queues can process commands simultaneously
- **Queue Priority**: Supports queue priority scheduling
- **Interrupt Aggregation**: Interrupts from multiple completion queues can be aggregated, reducing CPU interrupt overhead

**Implementation Features**:
- Uses SpinalHDL to implement type-safe queue management
- Hardware-implemented queue pointer management, avoiding software overhead
- Supports MSI/MSI-X interrupt mechanisms
- Directly connects with TOE module through AXI-Stream interface, achieving zero-copy

### DMA Engine

**SGDMA (Scatter-Gather DMA)** engine implements efficient data transfer:

**Features**:
- **Scatter/Gather Transfer**: Supports transfer of non-contiguous memory regions
- **Automatic Page Boundary Handling**: Automatically handles transfers across page boundaries
- **Multi-Channel Support**: Supports multiple independent DMA channels
- **Priority Scheduling**: Supports channel priority scheduling

**Integration with NVMe**:
- DMA engine directly connects with NVMe controller
- Supports NVMe's PRP (Physical Region Page) and SGL (Scatter-Gather List) descriptors
- Automatically handles data transfer for NVMe commands

**Performance Optimization**:
- Uses AXI4 burst transfer to improve bandwidth utilization
- Supports prefetch mechanism to reduce latency
- Hardware-implemented descriptor list traversal, reducing CPU load

## Network Acceleration Implementation

### Load Balancing and Failover

OpenNAS provides **4× 10Gbps network interfaces**, supporting multiple aggregation modes:

**Load Balancing Modes**:
- **Round-Robin**: Distributes traffic to each interface in sequence
- **Least Connections**: Assigns new connections to the interface with the fewest connections
- **Hash**: Hashes based on source/destination IP and port, ensuring the same connection uses the same interface
- **Weighted Round-Robin**: Distributes traffic based on interface weights

**Failover Modes**:
- **Active-Standby**: One primary interface works, others serve as backup
- **Link Aggregation**: Multiple interfaces aggregated into one logical interface, improving bandwidth and reliability

**Application Scenarios**:
- **Dual-Port NIC Direct Connection**: Two devices connected via dual-port direct connection, achieving high bandwidth and redundancy
- **Multi-Path Transfer**: Utilizes multiple network paths to increase total bandwidth
- **Network Redundancy**: Automatically switches to other interfaces when one interface fails

**Implementation Details**:
- Hardware-implemented load balancing algorithms, low latency
- Real-time interface status monitoring, fast fault detection
- Supports LACP (Link Aggregation Control Protocol)
- Integrated with TOE module, achieving transparent load balancing

## Energy Efficiency Optimization Implementation

### Fan Curve

OpenNAS uses **XADC (Xilinx Analog-to-Digital Converter)** to read temperature and controls fan speed according to configured fan curve.

**XADC Interface**:
- **Temperature Sensor**: Reads FPGA internal temperature sensor
- **External Temperature Sensors**: Supports connecting external temperature sensors (e.g., CPU, NVMe SSD, etc.)
- **12-bit ADC**: High-precision temperature measurement
- **Sampling Frequency**: Configurable sampling frequency

**Fan Curve Configuration**:
- **Multi-Segment Linear Curve**: Supports configuring multi-segment linear fan curves
- **Temperature Thresholds**: Configurable multiple temperature threshold points
- **Speed Range**: Supports PWM control, speed range 0-100%
- **Smooth Control**: Uses PID controller to achieve smooth fan speed adjustment

**Typical Fan Curve**:
```
Temperature < 40°C:  Fan speed 20%
40°C - 50°C: Fan speed 20% - 40% (linear)
50°C - 60°C: Fan speed 40% - 60% (linear)
60°C - 70°C: Fan speed 60% - 80% (linear)
Temperature > 70°C:  Fan speed 100%
```

**Implementation Method**:
- Uses SpinalHDL to implement temperature monitoring module
- Hardware-implemented PID controller, fast response
- Supports configuring fan curve parameters through AXI4-Lite interface
- Real-time temperature monitoring and fan control, no CPU intervention required

**Safety Features**:
- **Over-Temperature Protection**: Automatically increases fan speed or reduces operating frequency when temperature exceeds safety threshold
- **Fault Detection**: Detects fan faults (e.g., stopped) and alarms
- **Temperature History**: Records temperature history data for analysis and optimization

## Simulation and Verification

### Verification Methods

1. **Unit Testing**: Each module tested independently using SpinalHDL's testing framework
2. **Integration Testing**: Interface testing between modules, verifying data flow correctness
3. **System Testing**: Complete functionality testing, including end-to-end data transfer
4. **Performance Testing**: Throughput and latency testing, verifying design goals are met

### Simulation Tools

**XSim (Vivado Simulator)**:
- Built-in Vivado simulator
- Supports Verilog, VHDL, SystemVerilog
- Seamless integration with Vivado toolchain

**Verilator**:
- Open-source Verilog simulator
- High performance, suitable for large-scale simulation
- Supports SystemVerilog subset

### Debugging Tips

1. **ILA (Integrated Logic Analyzer)**: Use Vivado ILA for online debugging, viewing signal waveforms in real-time
2. **Simulation Waveforms**: Use XSim or Verilator to view detailed waveforms, analyze timing issues
3. **Log Output**: Use `println` in SpinalHDL code to output debug information
4. **Assertions**: Use SystemVerilog assertions to check design constraints

## Development Guidelines

### SpinalHDL Code Example


### Mixed Design



## References

- [Xilinx Zynq-7000 Technical Documentation](https://www.xilinx.com/products/silicon-devices/soc/zynq-7000.html)
- [SpinalHDL Official Documentation](https://spinalhdl.github.io/SpinalDoc-RTD/)
- [PCIe Specification](https://pcisig.com/)
- [NVMe Specification](https://nvmexpress.org/)
- [TCP/IP Protocol Details](https://tools.ietf.org/html/rfc793)
- [AXI4 Specification](https://developer.arm.com/documentation/ihi0022/latest/)

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the project
2. Create a feature branch
3. Write code and tests (using SpinalHDL or Verilog)
4. Ensure all tests pass
5. Submit a Pull Request

For more information, please refer to the project's contribution guidelines.
