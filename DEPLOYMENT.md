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

```mermaid
graph TD
    Modem["ISP Modem"] --> FW["Firewall"]
    FW --> Switch["Managed Switch"]

    Switch --> AP["WiFi AP - Port 2"]
    Switch --> Serv1["Server - Port 3"]
    Switch --> Serv2["Server Second NIC / SPAN - Port 4"]
    Switch --> Res["Reserved - Port 5"]