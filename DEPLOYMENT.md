# Deployment Guide: Enterprise-Grade SOC Lab

This guide provides step-by-step instructions to replicate this security operations center environment from bare metal to operational threat detection platform.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Hardware Setup](#hardware-setup)
3. [Network Infrastructure Configuration](#network-infrastructure-configuration)
4. [Hypervisor Installation & Configuration](#hypervisor-installation--configuration)
5. [Firewall Deployment](#firewall-deployment)
6. [Infrastructure as Code Provisioning](#infrastructure-as-code-provisioning)
7. [Security Onion Configuration](#security-onion-configuration)
8. [Attack Lab Setup](#attack-lab-setup)
9. [Validation & Testing](#validation--testing)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Hardware

| Component | Minimum Specs | Recommended | Purpose |
|-----------|---------------|-------------|---------|
| **Firewall Appliance** | 4-core CPU, 8GB RAM, 2x GbE NICs | 6-core, 16GB, 4x GbE | Stateful inspection, VLAN routing |
| **Managed Switch** | 5-port, 802.1Q VLAN, Port Mirroring | 8-port, GbE, web-managed | VLAN segmentation, SPAN |
| **Hypervisor Server** | 4-core CPU, 32GB RAM, 500GB SSD | 8-core, 64GB, 1TB NVMe | VM hosting |
| **Additional NIC** | USB 3.0 Gigabit Ethernet adapter | PCIe GbE card | SPAN traffic ingestion |
| **Wireless AP** | 802.11ac, VLAN support | WiFi 6, management VLAN | Isolated wireless network |

### Required Software

- **Hypervisor Platform:** Proxmox VE 8.x+ (or equivalent Type 1 hypervisor)
- **Firewall OS:** Sophos XG Home / pfSense / OPNsense
- **NSM Platform:** Security Onion 3.x ISO
- **Attack Platform:** Kali Linux 2024.x ISO
- **Victim Target:** Metasploitable VMDK
- **IaC Tooling:** Terraform 1.9+ with hypervisor provider
- **ISP Connection:** Static or dynamic public IP with port forwarding capability

### Skills Required

- Linux command line proficiency
- Basic networking (subnetting, VLANs, routing)
- Firewall policy configuration
- Virtualization concepts
- Infrastructure as Code basics

---

## Hardware Setup

### Step 1: Physical Topology Assembly

---
graph TD
    %% Nodes
    Modem([ISP Modem])
    FW[Firewall]
    Switch[Managed Switch]
    AP[WiFi AP]
    Server[Server]
    SPAN[Server - Second NIC]

    %% Connections
    Modem -->|WAN Port| FW
    FW -->|LAN Port / Port 1| Switch
    
    %% Switch Port Breakouts
    Switch -->|Port 2| AP
    Switch -->|Port 3| Server
    Switch -->|Port 4: SPAN| SPAN
    Switch -.->|Port 5| Reserved[Reserved]

    %% Styling
    style Modem fill:#f9f,stroke:#333,stroke-width:2px
    style FW fill:#ff9,stroke:#333,stroke-width:2px
    style Switch fill:#bbf,stroke:#333,stroke-width:2px
    style Reserved stroke-dasharray: 5 5