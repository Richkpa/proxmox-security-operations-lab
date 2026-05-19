# Enterprise-Grade Network Security Monitoring & Threat Detection Lab

![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform)
![Proxmox](https://img.shields.io/badge/Hypervisor-Proxmox-E57000?logo=proxmox)
![Security Onion](https://img.shields.io/badge/NSM-Security%20Onion%203.0-00A98F)
![Sophos](https://img.shields.io/badge/Firewall-Sophos%20Home-blue)

**A production-grade hybrid physical‑virtual SOC environment demonstrating advanced network defense, threat detection engineering, and Infrastructure as Code automation.**

**Quick Links:** [Architecture Diagram](#network-architecture-diagram) | [Deep‑Dive Analysis](#deep-dive-technical-analysis--design-rationales) | [Threat Simulation Guide](#lab-execution-guide-end-to-end-threat-simulation) | [Terraform Code](terraform/) | [Screenshots](docs/screenshots/) | [Deployment Notes](#deployment-notes--troubleshooting)

---

## Executive Summary

This repository documents a fully operational home lab built to SOC engineering standards. It proves practical competency in network security monitoring (NSM), zero‑trust segmentation, out‑of‑band traffic analysis, and automated infrastructure deployment—skills directly transferable to enterprise blue team and detection engineering roles.

**Business Value Proposition:**
- **Threat Detection Engineering:** Real‑time intrusion detection via Security Onion 3.0 using Zeek and Suricata correlation against live attack traffic.
- **Network Segmentation Strategy:** Multi‑zone architecture isolating production, SOC infrastructure, attack simulation, and vulnerable victim environments with explicit deny‑by‑default policies.
- **Zero‑Trust Enforcement:** Firewall rules that prevent lateral movement from compromised attack or victim segments while maintaining full visibility through hardware SPAN mirroring.
- **Operational Automation:** Terraform‑managed VMs eliminating configuration drift and enabling repeatable SOC deployments.
- **Hands‑On IR Workflow:** Complete attack → detect → triage lifecycle with MITRE ATT&CK mapping and forensic documentation.

---

## Network Architecture Diagram

### Interactive Mermaid.js (renders natively on GitHub)

```mermaid
graph TD
    Internet((Internet)) -->|Dynamic Public IP| ATTModem["AT&T Modem<br/>(IP Passthrough)"]
    ATTModem --> SophosFW["Sophos Firewall<br/>Qotom Mini PC<br/>Port2: WAN"]
    SophosFW -->|Port1 LAN Trunk<br/>192.168.*.*/24| Switch["TP-Link<br/>Smart Managed Switch"]
    Switch -->|Port2 Access Trunk<br/>VLAN80 untagged| AP["WiFi AP<br/>(VLAN80 Subnet)"]
    Switch -->|Port3 Trunk<br/>VLANs 1, 10, 30, 40| ProxNIC0["Proxmox NIC0<br/>vmbr0 (VLAN-Aware)"]
    Switch -->|Port4 SPAN Destination| ProxNIC1["Proxmox USB NIC<br/>vmbr1 (Promiscuous)"]
    
    subgraph Proxmox_VE [Proxmox VE 9.x]
        vmbr0["Linux Bridge vmbr0<br/>VLAN-Aware (nic0)"]
        vmbr1["Linux Bridge vmbr1<br/>SPAN Traffic Ingest (USB NIC)"]
        ProxNIC0 --- vmbr0
        ProxNIC1 --- vmbr1
        
        subgraph VMs
            SO["VM10: Security Onion 3.0<br/>net0: vmbr0 tag=10 (Mgmt)<br/>net1: vmbr1 (Sniffing)"]
            Kali["VM30: Kali Linux<br/>net0: vmbr0 tag=30 (Attack)"]
            Meta["VM40: Metasploitable 2<br/>net0: vmbr0 tag=40 (Victim)"]
        end
        
        vmbr0 -->|VLAN10| SO
        vmbr0 -->|VLAN30| Kali
        vmbr0 -->|VLAN40| Metasploit
        vmbr1 --> SO
    end

    Switch --- SPANLogic{{"Port Mirroring<br/>Source: Port1, Port2<br/>Destination: Port4"}}
    SPANLogic -.->|Copies all Port1/2 traffic| ProxNIC1

### Detailed ASCII Diagram

                               INTERNET
                                  │
                                  ▼
                        ┌─────────────────────┐
                        │   AT&T Fiber Modem  │
                        │  (IP Passthrough)   │
                        └──────────┬──────────┘
                                   │
                                   │ WAN (Dynamic Public IP)
                                   ▼
                ┌──────────────────────────────────────┐
                │  Sophos XG Firewall (Qotom Q555G6)   │
                │  ┌────────────────────────────────┐  │
                │  │ Port1 (LAN): 192.168.1.1/24   │  │
                │  │ VLAN10: 192.168.10.1/24 (SOC) │  │
                │  │ VLAN20: 192.168.20.1/24 (IoT) │  │
                │  │ VLAN30: 192.168.30.1/24 (ATK) │  │
                │  │ VLAN40: 192.168.40.1/24 (VIC) │  │
                │  │ VLAN80: 192.168.80.1/24 (WiFi)│  │
                │  └────────────────────────────────┘  │
                └──────────────┬───────────────────────┘
                               │ Trunk (802.1Q Tagged)
                               ▼
          ┌────────────────────────────────────────────┐
          │   TP-Link TL-SG105E (Managed Switch)       │
          │  ┌──────────────────────────────────────┐  │
          │  │ Port 1: Trunk (VLAN 1,10,30,40,80)   │  │
          │  │ Port 2: Access WiFi AP (VLAN 80)     │  │
          │  │ Port 3: Trunk to Proxmox (VLANs)     │  │
          │  │ Port 4: SPAN Mirror Destination      │  │
          │  │ Port 5: Reserved                     │  │
          │  └──────────────────────────────────────┘  │
          │  SPAN Config: Ports 1,2 → Port 4          │
          └───┬─────────────────────┬──────────────────┘
              │                     │
     Port 3   │                     │ Port 4 (SPAN Stream)
              ▼                     ▼
┌─────────────────────────────────────────────────────┐
│      Dell OptiPlex 3040 (Proxmox VE 9.1.11)         │
│  ┌───────────────────────────────────────────────┐  │
│  │ vmbr0 (nic0) ←─ Port 3 (VLAN-aware bridge)   │  │
│  │ vmbr1 (USB NIC) ←─ Port 4 (Promiscuous)      │  │
│  └───────────────────────────────────────────────┘  │
│                                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │ VM 100: Security Onion 3.0.0                 │  │
│  │  ├─ net0 → vmbr0.10 (192.168.10.x)          │  │
│  │  │   Management Interface (SSH/WebUI)        │  │
│  │  └─ net1 → vmbr1 (Promiscuous Mode)         │  │
│  │      Sniffing Interface (Zeek/Suricata)     │  │
│  │  Resources: 4 vCPU, 16GB RAM, 300GB Storage │  │
│  └──────────────────────────────────────────────┘  │
│                                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │ VM 101: Kali Linux (Attack Platform)         │  │
│  │  └─ net0 → vmbr0.30 (192.168.30.x)          │  │
│  └──────────────────────────────────────────────┘  │
│                                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │ VM 300: Metasploitable 2 (Victim)            │  │
│  │  └─ net0 → vmbr0.40 (192.168.40.x)          │  │
│  └──────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘

TRAFFIC FLOW LEGEND:
═══════════════════════════════════════════════════════
Management Traffic:   vmbr0.10 → Security Onion net0
SPAN Mirror Traffic:  Switch Port 4 → USB NIC → vmbr1 → Security Onion net1
Attack Traffic:       Kali (VLAN30) → Metasploitable (VLAN40) [allowed]
Blocked Egress:       Victim (VLAN40) ✗→ SOC (VLAN10), LAN, WiFi
