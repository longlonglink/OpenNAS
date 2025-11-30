---
title: OpenNAS Project
nav_order: 1
---

# OpenNAS Open Source Project

OpenNAS is a high-performance, low-power open-source Network Attached Storage (NAS) project based on FPGA. This project adopts a fully open-source design philosophy, with all code and design documents open to the community from hardware to software, from firmware to applications, dedicated to helping users regain sovereignty over their data.

## Hardware

### 1. Main Control Chip

We have chosen the **Xilinx Zynq-7000 series FPGA** as the core processor, specifically the **XC7Z035-FFG900** model.

#### Why Choose FPGA?

- **Customizability**: The hardware-programmable nature of FPGA allows us to deeply optimize for storage and networking applications
- **High Performance**: Through hardware acceleration, I/O performance far exceeding traditional ARM or x86 processors can be achieved
- **Low Power Consumption**: Compared to general-purpose processors with equivalent performance, FPGA consumes less power in specific application scenarios
- **Open Source Friendly**: FPGA designs can be developed and verified using open-source toolchains

#### Technical Specifications

- **Logic Cells**: XC7Z035 provides 275K logic cells, sufficient to implement complex storage and network protocol stacks
- **ARM Dual-Core Cortex-A9**: Runs Linux operating system and upper-layer applications
- **DDR3 Controller**: Supports high-speed memory access
- **PCIe Interface**: Used to connect NVMe storage devices

### 2. Network Interface (SFP+)

OpenNAS provides **4× 10Gbps Ethernet interfaces** through SFP+ optical modules for high-speed network connectivity.

#### Design Features

- **10Gbps Bandwidth**: Each interface supports 10Gbps full-duplex communication, with total bandwidth up to 40Gbps
- **SFP+ Interface**: Supports various optical modules and direct-attach copper cables, flexibly adapting to different network environments
- **Hardware Acceleration**: Network protocol processing is implemented in FPGA hardware, reducing CPU load
- **Low Latency**: Hardware-implemented network stack can achieve microsecond-level latency

#### Application Scenarios

- High-speed file transfer and backup
- Media content distribution

### 3. Storage Interface (NVMe)

OpenNAS achieves direct access to NVMe solid-state drives through **PCIe soft core**.

#### Technical Implementation

- **PCIe Soft Core**: Implements PCIe protocol stack using Xilinx GT (Gigabit Transceiver) and RTL code
- **NVMe Protocol Support**: Complete NVMe 1.4 protocol implementation, supporting advanced features such as multi-queue and namespaces
- **Multi-Drive Support**: Can connect multiple NVMe SSDs simultaneously, enabling RAID or independent storage pools
- **High Performance**: Direct hardware access, avoiding overhead from traditional storage stacks

#### Performance Advantages

- **Low Latency**: Hardware-implemented PCIe and NVMe protocol stacks, latency can be as low as microsecond level
- **High Throughput**: Fully utilizes the parallel performance of NVMe SSDs
- **Scalable**: Can support more storage devices through PCIe expansion

#### Open Source Design

- **RTL Code Open Source**: All PCIe and NVMe related RTL code is completely open source
- **Customizable**: Community can modify and optimize storage protocol implementation according to needs
- **Transparency**: Users can fully understand how data is stored and accessed

## Software

### System Architecture

OpenNAS software stack adopts a layered design, from bottom to top including:

#### 1. Operating System Layer

- **Linux Kernel**: Based on mainline Linux kernel, optimized for storage and network applications
- **Device Drivers**: Provides complete driver support for FPGA hardware
- **Resource Management**: Efficient CPU, memory, and I/O resource scheduling

#### 2. Storage Management Layer

- **File Systems**: Supports various modern file systems (ZFS, Btrfs, etc.)
- **Storage Pool Management**: Flexible storage pool configuration and management
- **Data Protection**: RAID, snapshots, backup, and other data protection mechanisms
- **Performance Optimization**: Intelligent caching, read-ahead, write merging, and other optimization strategies

#### 3. Network Service Layer

- **File Sharing Protocols**: Supports mainstream protocols such as SMB, NFS, FTP, SFTP
- **Web Management Interface**: Modern Web UI for convenient remote management
- **Security Authentication**: Complete user permission management and access control

#### 4. Application Service Layer

- **Media Servers**: Supports Plex, Jellyfin, and other media servers
- **Cloud Sync**: Supports Nextcloud, ownCloud, and other private cloud solutions
- **Container Support**: Docker containerized application deployment
- **Web 3.0 Applications**: Decentralized storage and content publishing features

### Web 3.0 Features

OpenNAS is not just a storage device, but also a personal multimedia publishing platform:

- **Decentralized Content Publishing**: Supports decentralized protocols such as IPFS and ActivityPub
- **Content Sovereignty**: Users have complete control over their content and data
- **Freedom from Platform Constraints**: No dependency on centralized platforms, freely publish and share content
- **Privacy Protection**: Content stored locally, users decide sharing scope

### Open Source Ecosystem

- **Fully Open Source**: All software code is released under open source licenses
- **Community Driven**: Welcomes community contributions of code and features
- **Comprehensive Documentation**: Provides detailed technical documentation and development guides
- **Easy to Extend**: Modular design, convenient to add new features

## Firmware

### TCP Offload Engine (TOE)

OpenNAS implements a **TCP Offload Engine (TOE)** in FPGA, transferring TCP protocol processing from CPU to hardware, significantly improving network performance.

#### Technical Advantages

- **CPU Offload**: TCP protocol stack implemented in FPGA hardware, freeing CPU resources for other tasks
- **Low Latency**: Hardware-implemented TCP processing with much lower latency than software implementation
- **High Throughput**: Can easily achieve 10Gbps line-rate forwarding
- **Low Power Consumption**: Dedicated hardware is more energy-efficient than general-purpose CPU for network protocol processing

#### Implementation Features

- **Complete TCP/IP Protocol Stack**: Supports TCP, UDP, ICMP, and other protocols
- **Connection Management**: Supports large numbers of concurrent connections
- **Traffic Control**: Hardware-implemented congestion control and traffic shaping
- **Security Features**: Supports IPsec, TLS offload, and other security acceleration

### Other Firmware Features

#### 1. Storage Acceleration

- **NVMe Queue Management**: Hardware-implemented command queues and completion queues
- **DMA Engine**: Efficient data transfer mechanism
- **Cache Management**: Intelligent read/write caching strategies

#### 2. Network Acceleration

- **Packet Processing**: Hardware-implemented packet classification, filtering, and forwarding
- **Load Balancing**: Load balancing across multiple network interfaces
- **QoS Guarantee**: Quality of service guarantee mechanisms

#### 3. Energy Efficiency Optimization

- **Thermal Management**: Temperature monitoring and dynamic adjust fan speed

### Open Source Firmware

- **RTL Code Fully Open Source**: All FPGA firmware code is open source
- **Development Toolchain**: Currently using Vivado, with plans to support open-source FPGA toolchains (such as Yosys, nextpnr) in the future
- **Simulation and Verification**: Provides complete test platforms and verification environments
- **Documentation and Tutorials**: Detailed firmware development documentation

## Project Goals

### Technical Goals

- **High Performance**: Achieve 10Gbps network throughput and microsecond-level latency
- **Low Power Consumption**: Power consumption more than 50% lower than traditional solutions at equivalent performance
- **High Reliability**: 7×24 hours stable operation, zero data loss
- **Ease of Use**: Ready to use out of the box, simple configuration

### Open Source Goals

- **Complete Transparency**: Hardware, software, and firmware all open source
- **Community Collaboration**: Welcomes global developers to participate and contribute
- **Knowledge Sharing**: All design documents and technical details are public
- **Continuous Improvement**: Constantly optimized and improved based on community feedback

### Application Scenarios

- **Personal Data Storage**: Home NAS, personal cloud storage
- **Small Business Storage**: Small business file servers
- **Media Center**: Home media servers, content distribution
- **Development and Testing**: Developer test storage environments
- **Edge Computing**: Storage and computing platforms for edge nodes

## Contributing

OpenNAS is a fully open-source project, and we welcome all forms of contributions:

- **Code Contributions**: Hardware design, software development, firmware optimization
- **Documentation Improvement**: Technical documentation, user manuals, tutorials
- **Testing and Feedback**: Bug reports, performance testing, user experience
- **Community Support**: Answering questions, helping new users, promoting the project

Let's build a truly user-owned open-source storage solution together!
