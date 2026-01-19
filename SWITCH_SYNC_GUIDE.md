# Switch Configuration Sync Guide

This guide explains how to use the reference switch configuration sync process to maintain consistent configurations across similar switches.

## Overview

The sync process uses a "golden config" approach:
- **IDF Switches**: `sw-idf1` is the reference switch
- **Core Switches**: `sw-core1` is the reference switch

All other switches in each group should match the reference switch's VLAN and port configuration (with only management IP and hostname differences).

## Quick Start

### Sync IDF Switches

Pull configuration from sw-idf1 and prepare to apply to sw-idf2 and sw-idf3:

```bash
make sync-idf
```

### Sync Core Switches

Pull configuration from sw-core1 and prepare to apply to sw-core2:

```bash
make sync-core
```

### Sync All Switches

Pull configurations from both reference switches:

```bash
make sync-all
```

## What the Sync Process Does

### 1. Pull Phase (Automated)

The playbook will:
- ✅ Connect to the reference switch (sw-idf1 or sw-core1)
- ✅ Pull the complete running configuration
- ✅ Pull VLAN configuration
- ✅ Pull port/interface configuration
- ✅ Pull spanning tree configuration
- ✅ Pull trunk/LAG configuration
- ✅ Save timestamped backups to `backups/zyxel/`
- ✅ Save reference config as template in `templates/`

### 2. Backup Phase (Automated)

For each target switch:
- ✅ Pull current configuration
- ✅ Save pre-sync backup with timestamp
- ✅ Prompt for confirmation before proceeding

### 3. Apply Phase (Manual - See Below)

The sync playbooks **DO NOT** automatically apply configurations. They only:
- Pull and save reference configs
- Create backups of target switches
- Prepare templates for manual review

## Files Created

After running sync, you'll find:

```
backups/zyxel/
├── idf1_reference_latest.txt          # Latest IDF reference config
├── idf1_reference_YYYYMMDD-HHMMSS.txt # Timestamped IDF reference
├── idf1_vlans_YYYYMMDD-HHMMSS.txt     # VLAN config
├── idf1_port_vlans_YYYYMMDD-HHMMSS.txt # Port VLAN assignments
├── core1_reference_latest.txt         # Latest Core reference config
├── core1_reference_YYYYMMDD-HHMMSS.txt # Timestamped Core reference
├── core1_vlans_YYYYMMDD-HHMMSS.txt    # VLAN config
├── core1_stp_YYYYMMDD-HHMMSS.txt      # Spanning tree config
├── sw-idf2_pre_sync_YYYYMMDD-HHMMSS.txt # Pre-sync backup
└── sw-core2_pre_sync_YYYYMMDD-HHMMSS.txt # Pre-sync backup

templates/
├── idf_reference_config.txt           # IDF golden config
└── core_reference_config.txt          # Core golden config
```

## Applying Configurations

### Option 1: Manual Application (Recommended for First Time)

1. **Review the reference config:**
   ```bash
   cat backups/zyxel/idf1_reference_latest.txt
   # or
   cat backups/zyxel/core1_reference_latest.txt
   ```

2. **Connect to target switch via SSH:**
   ```bash
   ssh admin@172.19.1.18  # sw-idf2
   ```

3. **Enter configuration mode and apply relevant sections:**
   ```
   configure terminal
   
   # Apply VLAN configuration
   vlan 1
     name CORE
   vlan 102
     name INT
   # ... etc
   
   # Apply port configuration
   interface port-channel 1
     switchport mode trunk
   # ... etc
   
   # Save configuration
   write memory
   ```

### Option 2: Configuration File Upload

1. **Edit the reference config** to replace hostname and management IP:
   ```bash
   cp backups/zyxel/idf1_reference_latest.txt /tmp/sw-idf2-config.txt
   # Edit /tmp/sw-idf2-config.txt to change:
   # - hostname sw-idf1 -> hostname sw-idf2
   # - ip address 172.19.1.17 -> ip address 172.19.1.18
   ```

2. **Upload via TFTP/SCP** (if supported by Zyxel):
   ```bash
   scp /tmp/sw-idf2-config.txt admin@172.19.1.18:/tmp/
   ```

3. **Apply on switch:**
   ```
   copy /tmp/sw-idf2-config.txt running-config
   write memory
   ```

### Option 3: Ansible Deployment (Future Enhancement)

Create a deployment playbook that:
- Parses the reference config
- Generates switch-specific configs
- Applies via Ansible network modules

## Important Considerations

### IDF Switches
- ✅ All IDF switches should have identical VLAN configurations
- ✅ All IDF switches should have identical port configurations
- ⚠️  Only management IP and hostname should differ
- ⚠️  Verify uplink ports match your physical topology

### Core Switches
- ✅ Core switches should have identical VLAN configurations
- ✅ Core switches should have identical port configurations
- ⚠️  **Spanning Tree Priority**: Core1 should be root (priority 4096), Core2 should be backup (priority 8192)
- ⚠️  Verify firewall connections on ports 1-2
- ⚠️  Verify core interconnect on ports 3-8

## Verification After Sync

After applying configuration to a switch, verify:

```bash
# Check VLAN configuration
show vlan

# Check port status
show interface status

# Check spanning tree
show spanning-tree

# Check trunk/LAG status
show trunk

# Verify connectivity
ping 172.19.1.15  # Core1
ping 172.19.1.252 # pfSense1
```

## Rollback Procedure

If something goes wrong:

1. **Locate the pre-sync backup:**
   ```bash
   ls -lt backups/zyxel/sw-idf2_pre_sync_*
   ```

2. **Apply the backup configuration:**
   ```bash
   # Via SSH to switch
   copy tftp://your-tftp-server/sw-idf2_pre_sync_TIMESTAMP.txt running-config
   write memory
   ```

## Troubleshooting

### Connection Issues
```bash
# Test connectivity
ansible sw-idf1.disconet.work -m ping

# Check SSH access
ssh admin@172.19.1.17
```

### Permission Issues
```bash
# Verify credentials in inventory
cat inventory/host_vars/sw-idf1.disconet.work.yml
```

### Playbook Errors
```bash
# Run with verbose output
ansible-playbook playbooks/sync_idf_switches.yml -vvv
```

## Best Practices

1. **Always review** reference configs before applying
2. **Test on one switch** before applying to all
3. **Keep backups** of all configurations
4. **Document changes** in git commits
5. **Schedule maintenance windows** for config changes
6. **Verify connectivity** after each change
7. **Update reference switch** when making intentional changes

## Workflow Example

Complete workflow for syncing IDF switches:

```bash
# 1. Pull reference config from IDF1
make sync-idf

# 2. Review the reference config
cat backups/zyxel/idf1_reference_latest.txt

# 3. Review pre-sync backup of target
cat backups/zyxel/sw-idf2_pre_sync_*.txt

# 4. Apply to first target switch (sw-idf2)
# ... manual application via SSH or web UI ...

# 5. Verify sw-idf2 is working correctly
ansible sw-idf2.disconet.work -m ping

# 6. Apply to remaining switches (sw-idf3)
# ... manual application ...

# 7. Verify all switches
ansible idf_switches -m ping

# 8. Commit changes to git
git add backups/ templates/
git commit -m "Synced IDF switches from sw-idf1 reference"
```

