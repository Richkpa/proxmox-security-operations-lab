# Prerequisites

**Navigation:** [README](../README.md) | [Hardware Setup →](02-HARDWARE-SETUP.md)

---

## Overview

This guide lists all hardware, software, and skill prerequisites required to build the SOC lab environment.

**Time to review:** 15-30 minutes  
**Cost estimate:** $800-$1,500 (excluding existing hardware)

---

## Table of Contents

1. [Required Hardware](#required-hardware)
2. [Required Software](#required-software)
3. [Required Skills](#required-skills)
4. [Network Requirements](#network-requirements)
5. [Optional Components](#optional-components)
6. [Pre-Deployment Checklist](#pre-deployment-checklist)

---

## Required Hardware

### Core Infrastructure

| Component | Minimum Specs | Recommended | Estimated Cost | Notes |
|-----------|---------------|-------------|----------------|-------|
| **Firewall Appliance** | 4-core CPU, 8GB RAM, 2x GbE NICs | Intel J4125, 16GB, 4x GbE | $200-$400 | Mini PC or dedicated appliance |
| **Managed Switch** | 5-port, 802.1Q VLAN, Port Mirroring | 8-port GbE, Web GUI | $50-$150 | TP-Link, Netgear, or equivalent |
| **Hypervisor Server** | 4-core CPU, 16GB RAM, 500GB SSD | 8-core, 32GB, 1TB NVMe | $300-$800 | Dell OptiPlex, HP EliteDesk, or custom build |
| **Additional NIC** | USB 3.0 GbE adapter | PCIe GbE card | $15-$40 | For SPAN traffic ingestion |
| **Wireless AP** | 802.11ac, VLAN support | WiFi 6, managed | $50-$150 | TP-Link EAP, Ubiquiti UAP |

**Total Hardware Cost:** $615 - $1,540

### Detailed Hardware Requirements

#### Firewall Appliance

**Minimum:**
- CPU: 4 cores @ 2.0 GHz or higher
- RAM: 8GB DDR4
- Storage: 64GB SSD/eMMC
- Network: 2x Gigabit Ethernet (WAN + LAN)
- Ports: At least 4 total NICs (1 WAN + 3 LAN for future expansion)

**Recommended:**
- CPU: Intel Celeron J4125 or better (6 cores preferred)
- RAM: 16GB DDR4
- Storage: 128GB M.2 SSD
- Network: 4x Intel i211/i225/i226 Gigabit NICs
- Form Factor: Fanless mini PC for silent operation

**Example Models:**
- Protectli Vault FW6 (6x GbE, i5 CPU)
- Qotom Mnin PC (6x GbE, Celeron J4125)
- Custom build with PC Engines APU2

#### Managed Switch

**Minimum:**
- Ports: 5x Gigabit Ethernet
- Features: 802.1Q VLAN tagging, Port Mirroring (SPAN)
- Management: CLI or Web GUI
- VLAN Support: At least 10 VLANs

**Recommended:**
- Ports: 8x Gigabit Ethernet
- Features: 802.1Q, SPAN, LLDP, Jumbo Frames
- Management: Web GUI with HTTPS
- VLAN Support: 64+ VLANs
- PoE: Optional (for powering WiFi AP)

**Example Models:**
- TP-Link TL-SG105E (5-port, budget)
- TP-Link TL-SG108E (8-port, PoE version available)
- Netgear GS308T (8-port, advanced features)

#### Hypervisor Server

**Minimum:**
- CPU: 4 cores, VT-x/AMD-V support
- RAM: 32GB DDR4 (16GB absolute minimum)
- Storage: 500GB SATA SSD
- Network: 1x Gigabit Ethernet onboard
- Expansion: 1x USB 3.0 port or PCIe slot for second NIC

**Recommended:**
- CPU: Intel i5-8500T or AMD Ryzen 5 3600 (6-8 cores)
- RAM: 64GB DDR4 (allows more VMs)
- Storage: 1TB NVMe SSD
- Network: 1x onboard GbE + 1x PCIe GbE card
- Case: Small form factor (SFF) for desk placement

**Example Models:**
- Dell OptiPlex 3040/5040/7040 (used, $150-$400)
- HP EliteDesk 800 G2/G3 (used, $200-$500)
- Lenovo ThinkCentre M720q (used, $250-$600)
- Custom build with AMD Ryzen

**RAM Allocation Breakdown:**

Security Onion:    16GB (minimum 12GB)
Kali Linux:         4GB
Metasploitable:     1GB
Proxmox Host:       4GB
Future VMs:         8GB reserve
─────────────────────────
Total:             24GB → 32GB minimum, 64GB recommended

#### Additional Network Interface (SPAN Capture)

**Option A: USB 3.0 Gigabit Adapter**
- Pros: No installation, portable, works with any USB 3.0 port
- Cons: Slightly higher CPU overhead, potential driver issues
- Examples: Cable Matters USB 3.0 GbE, Anker USB 3.0 to Ethernet

**Option B: PCIe Gigabit Network Card**
- Pros: Lower CPU overhead, native Linux support, more reliable
- Cons: Requires PCIe slot, installation required
- Examples: Intel I350-T2 (dual-port), Intel I210/I211 single-port

**Recommended:** PCIe card for production stability; USB for testing/proof-of-concept.

---

## Required Software

### Operating Systems & Images

| Software | Version | Download Source | Size | License |
|----------|---------|-----------------|------|---------|
| **Proxmox VE** | 8.2+ | [proxmox.com](https://www.proxmox.com/en/downloads) | ~1GB ISO | Open Source (AGPL) |
| **Security Onion** | 3.0+ | [securityonion.net](https://github.com/Security-Onion-Solutions/securityonion/releases) | ~3GB ISO | Open Source (GPL) |
| **Kali Linux** | 2024.1+ | [kali.org](https://www.kali.org/get-kali/) | ~4GB ISO | Open Source (GPL) |
| **Metasploitable 3** | 3.0 | [SourceForge](https://sourceforge.net/projects/metasploitable/) | ~900MB VMDK | Open Source |
| **Sophos XG Home** | Latest | [sophos.com](https://www.sophos.com/en-us/products/free-tools/sophos-xg-firewall-home-edition) | ~600MB ISO | Free (Home License) |

**Alternative Firewalls (Open Source):**
- pfSense CE: [pfsense.org](https://www.pfsense.org/download/)
- OPNsense: [opnsense.org](https://opnsense.org/download/)

### Infrastructure as Code Tools

```bash
# Terraform (IaC provisioning)
Version: latest
Download: https://www.terraform.io/downloads

# Terraform Proxmox Provider
Provider: bpg/proxmox
Version: latest
Docs: https://registry.terraform.io/providers/bpg/proxmox/latest/docs
```

### Local Workstation Requirements

**For Terraform deployment and management:**
- OS: Linux, macOS, or Windows 10+
- Terminal: Bash, PowerShell, or Windows Terminal
- SSH Client: OpenSSH or PuTTY
- Text Editor: VS Code, Sublime, or nano/vim
- Web Browser: Chrome, Firefox, or Edge (for firewall/Proxmox UI)

---

## Required Skills

### Essential Knowledge

**Networking (Intermediate):**
- ✅ IP addressing and subnetting (CIDR notation)
- ✅ OSI model (Layers 2-4)
- ✅ VLAN concepts and 802.1Q tagging
- ✅ Basic routing and gateway concepts
- ✅ TCP/IP fundamentals

**Linux Administration (Basic-Intermediate):**
- ✅ Command line navigation (`cd`, `ls`, `pwd`)
- ✅ File editing (`nano`, `vim`)
- ✅ Package management (`apt`, `yum`)
- ✅ Service management (`systemctl`)
- ✅ Log file review (`journalctl`, `tail`, `grep`)

**Virtualization (Basic):**
- ✅ VM concepts (vCPU, RAM, disk allocation)
- ✅ Virtual networking (bridges, VLAN tagging)
- ✅ ISO mounting and VM installation

**Firewall Concepts (Basic-Intermediate):**
- ✅ Stateful vs stateless filtering
- ✅ Zone-based policies
- ✅ NAT (Network Address Translation)
- ✅ Rule ordering (top-down evaluation)

### Helpful But Not Required

- Infrastructure as Code (Terraform/Ansible)
- Security Onion administration
- Wireshark packet analysis
- Metasploit Framework
- Git version control

**Learning Resources:**
- Networking: Professor Messer's Network+ course (free on YouTube)
- Linux: Linux Journey (linuxjourney.com)
- Proxmox: Official Proxmox VE Administration Guide
- Security Onion: Official documentation at docs.securityonion.net

---

## Network Requirements

### Internet Connection

**Minimum:**
- Download Speed: 250 Mbps
- Upload Speed: 50 Mbps
- Data Cap: Unlimited or >500GB/month

**Recommended:**
- Download Speed: 500+ Mbps
- Upload Speed: 100+ Mbps
- Latency: <50ms to major DNS servers

**Required for:**
- Downloading OS images and updates (~10GB initial)
- Threat intelligence feed updates (1-5GB/month)
- Package repository access (apt, yum)
- Security Onion signature updates

### ISP Modem Configuration

**Required Capability:**
- **Bridge Mode** or **IP Passthrough** mode
- Ability to assign public IP to downstream device (firewall)

**How to Check:**
1. Log into ISP modem admin interface (usually `192.168.0.1` or `192.168.1.1`)
2. Look for settings labeled:
   - "Bridge Mode"
   - "IP Passthrough"
   - "Transparent Bridging"

**If unavailable:** Contact ISP to enable bridge mode or request a "business class" modem.

### Physical Workspace

- **Power:** 3-4 outlets (modem, firewall, switch, server)
- **Desk Space:** ~2 sq ft for stacked equipment
- **Ventilation:** Open airflow for fanless devices
- **Cable Management:** 5-10 Ethernet cables (Cat5e or Cat6)
- **Optional:** Small rack or shelf for organization

---

## Pre-Deployment Checklist

### Before You Begin

**Hardware Readiness:**
- [ ] Firewall appliance powered on and accessible
- [ ] Managed switch powered on and accessible
- [ ] Hypervisor server BIOS/UEFI configured (VT-x/AMD-V enabled)
- [ ] Additional NIC installed/connected
- [ ] All Ethernet cables available (at least 6x Cat5e/Cat6)
- [ ] Internet connection active and stable

**Software Readiness:**
- [ ] Proxmox VE ISO downloaded and verified
- [ ] Security Onion ISO downloaded and verified
- [ ] Kali Linux ISO downloaded and verified
- [ ] Metasploitable VMDK downloaded
- [ ] Firewall OS ISO downloaded (if not pre-installed)
- [ ] Terraform installed on local workstation

**Knowledge Readiness:**
- [ ] Reviewed network topology diagram
- [ ] Understand VLAN 10, 20, 30, 40, 50, 60 allocation
- [ ] Familiar with firewall zone concepts
- [ ] Basic Linux command line comfort
- [ ] Have notepad ready for documenting IP addresses and credentials

**Account Setup:**
- [ ] Password manager installed (for credential storage)
- [ ] GitHub account created (for Terraform code hosting)
- [ ] Text editor or IDE installed (VS Code, Sublime)

**Documentation Prepared:**
- [ ] This prerequisites guide reviewed
- [ ] Hardware setup guide opened and ready
- [ ] Network diagram printed or on second monitor

---

## Estimated Timeline

**Total Deployment Time:** 6-10 hours (can be split across multiple sessions)

| Phase | Time Estimate |
|-------|---------------|
| Hardware assembly and cabling | 1-2 hours |
| Firewall configuration | 1-2 hours |
| Switch VLAN and SPAN setup | 30-60 minutes |
| Proxmox installation and networking | 1-2 hours |
| Terraform VM provisioning | 30-60 minutes |
| Security Onion setup | 1-2 hours |
| Attack lab deployment | 30-60 minutes |
| Validation and testing | 1-2 hours |

**Recommended Approach:**
- **Session 1 (3-4 hours):** Hardware setup through firewall configuration
- **Session 2 (2-3 hours):** Proxmox and Terraform deployment
- **Session 3 (2-3 hours):** Security Onion and attack lab setup, validation

---

## Download Checklist & Verification

### ISO/Image Downloads

```bash
# Create download directory
mkdir -p ~/iso-downloads
cd ~/iso-downloads

# Download files (example URLs - verify current versions)
wget https://enterprise.proxmox.com/iso/proxmox-ve_8.2-1.iso
wget https://download.securityonion.net/file/securityonion/securityonion-3.0.0-YYYYMMDD.iso
wget https://cdimage.kali.org/kali-2024.1/kali-linux-2024.1-installer-amd64.iso

# Verify checksums (example)
sha256sum proxmox-ve_8.2-1.iso
# Compare against official website checksum
```

**Official Checksum Sources:**
- Proxmox: Listed on download page
- Security Onion: GitHub release page
- Kali: kali.org/get-kali (SHA256 tab)

---

## Cost Breakdown Summary

> [!IMPORTANT]
> * **Budget & Scalability:** If you are facing budget constraints, you can easily start small and scale your lab over time. For instance, this deployment initially began with just the firewall appliance, with the hypervisor server and managed switch integrated into the topology as resource demands and budget allowed.

### Budget Build (~$800)
Used Dell OptiPlex 5040 (i5, 32GB):  $300
Qotom Mini PC Firewall (4x GbE):     $250
TP-Link TL-SG108E (8-port switch):    $50
USB 3.0 GbE Adapter:                  $20
TP-Link WiFi AP:                      $100
Cables & Accessories:                 $30
──────────────────────────────────────
Total:                               $750

---

## Next Steps

**Prerequisites complete!**

Proceed to: **[Hardware Setup →](02-HARDWARE-SETUP.md)**

Or return to: **[README ←](../README.md)**

---

**Document Version:** 2.0  
**Last Updated:** May 2026  
**Estimated Setup Cost:** $800-$1,600