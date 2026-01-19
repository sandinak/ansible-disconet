# Inventory Import from DistrictCon Network Spreadsheet

This document summarizes the inventory imported from the `DistrictCon Network.ods` spreadsheet.

## Network Overview

- **Domain**: disconet.work
- **Routed Network**: 172.19.0.0/16

## VLANs Configured

| VLAN ID | Name | Subnet | Owner | Use Case |
|---------|------|--------|-------|----------|
| 1 | CORE | 172.19.1.0/24 | Dnet Team | Core-Switches |
| 102 | INT | 172.19.2.0/24 | Dnet Team | Internal Services |
| 103 | PUB | 172.19.3.0/24 | Dnet Team | Public Services |
| 104 | WIFIADMIN | 172.19.4.0/24 | Dnet Team | Wifi Admin |
| 105 | ADMIN | 172.19.5.0/25 | Dnet Team | Admin Lappyies |
| 115 | SYNC | 172.19.15.0/24 | Dnet Team | Loopbacks & ARP (NOT USED) |
| 116 | JTW | 172.19.16.0/24 | - | Jump the Wall |
| 117 | CFP | 172.19.17.0/24 | - | CFP |
| 118 | JUNK | 172.19.18.0/24 | - | Junkyard |
| 119 | SPEAKER | 172.19.19.0/24 | - | Speaker Wifi |
| 120 | REG | 172.19.20.0/24 | - | Registration |
| 228 | OPEN | 172.19.128.0/18 | DNet Team | Open Wifi |
| 292 | WPA | 172.19.192.0/18 | Dnet Team | WPA Wifi |

## Devices Added to Inventory

### Firewalls (pfsense group)
- **pfsense1.disconet.work** - 172.19.1.252 (Primary)
- **pfsense2.disconet.work** - 172.19.1.253 (Backup)
- Failover VIP: 172.19.15.1

### Core Switches (core_switches group)
- **sw-core1.disconet.work** - 172.19.1.15 (Primary)
- **sw-core2.disconet.work** - 172.19.1.16 (Backup)

### IDF Switches (idf_switches group)
- **sw-idf1.disconet.work** - 172.19.1.17
- **sw-idf2.disconet.work** - 172.19.1.18
- **sw-idf3.disconet.work** - 172.19.1.19 (Backup)

### Podium Switches (podium_switches group)
- **sw-pod1.disconet.work** - 172.19.1.20
- **sw-pod2.disconet.work** - 172.19.1.21
- **sw-pod3.disconet.work** - 172.19.1.22 (Backup)

### Special Purpose Switches (special_switches group)
- **sw-junk.disconet.work** - 172.19.1.23 (Junkyard)
- **sw-cfp.disconet.work** - 172.19.1.24 (CFP)

### Proxmox (proxmox group)
- **pve.disconet.work** - 172.19.1.30

### Network Equipment (peplink group)
- **peplink.disconet.work** - 172.19.0.1

## Port Configurations

### Core Switches
- Ports 1-2: Firewalls
- Ports 3-8: Core interconnects
- Ports 9-12: Access Points
- Ports 13-20: Admin devices
- Ports 21-24: Podium switches

### IDF Switches
- Ports 1-18: Access Points
- Ports 19-24: Podium connections
- Ports 25-28: Trunk uplinks to core

### Podium Switches
- Ports 1-5: Access Points (with WIFIADMIN tag)
- Ports 6-7: Access Points (basic)
- Port 8: Trunk to core

## Files Created/Updated

### Updated Files
- `inventory/hosts.yml` - Added all devices
- `inventory/group_vars/all/all.yml` - Updated domain and network settings
- `inventory/group_vars/all/networks.yml` - Complete VLAN definitions
- `inventory/group_vars/core_switches.yml` - Core switch port configuration
- `inventory/group_vars/idf_switches.yml` - IDF switch port configuration

### New Files Created
- `inventory/group_vars/podium_switches.yml` - Podium switch configuration
- `inventory/group_vars/special_switches.yml` - Special purpose switch configuration
- `inventory/host_vars/sw-core1.disconet.work.yml`
- `inventory/host_vars/sw-core2.disconet.work.yml`
- `inventory/host_vars/sw-idf1.disconet.work.yml`
- `inventory/host_vars/sw-idf2.disconet.work.yml`
- `inventory/host_vars/sw-idf3.disconet.work.yml`
- `inventory/host_vars/sw-pod1.disconet.work.yml`
- `inventory/host_vars/sw-pod2.disconet.work.yml`
- `inventory/host_vars/sw-pod3.disconet.work.yml`
- `inventory/host_vars/sw-junk.disconet.work.yml`
- `inventory/host_vars/sw-cfp.disconet.work.yml`
- `inventory/host_vars/pfsense1.disconet.work.yml`
- `inventory/host_vars/pfsense2.disconet.work.yml`
- `inventory/host_vars/pve.disconet.work.yml`
- `inventory/host_vars/peplink.disconet.work.yml`

## Next Steps

1. **Secure Credentials**: Move passwords to Ansible Vault
   ```bash
   ansible-vault create inventory/group_vars/all/vault.yml
   ```

2. **Test Connectivity**: Verify devices are reachable
   ```bash
   ansible all -m ping
   ```

3. **Backup Configurations**: Pull current configs from devices
   ```bash
   make pull
   ```

4. **Deploy Configurations**: Apply standardized configs
   ```bash
   make site
   ```

