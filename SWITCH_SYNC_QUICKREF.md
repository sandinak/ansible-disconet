# Switch Sync Quick Reference

## Commands

| Task | Command | Description |
|------|---------|-------------|
| Sync IDF switches | `make sync-idf` | Pull config from sw-idf1 |
| Sync Core switches | `make sync-core` | Pull config from sw-core1 |
| Sync all switches | `make sync-all` | Pull both reference configs |
| View reference config | `cat backups/zyxel/idf1_reference_latest.txt` | Review IDF reference |
| View reference config | `cat backups/zyxel/core1_reference_latest.txt` | Review Core reference |
| List backups | `ls -lt backups/zyxel/` | Show all backup files |

## Reference Switches

| Group | Reference Switch | IP Address | Target Switches |
|-------|-----------------|------------|-----------------|
| IDF | sw-idf1.disconet.work | 172.19.1.17 | sw-idf2, sw-idf3 |
| Core | sw-core1.disconet.work | 172.19.1.15 | sw-core2 |

## Files Created

```
backups/zyxel/
├── idf1_reference_latest.txt          ← IDF golden config
├── core1_reference_latest.txt         ← Core golden config
├── sw-idf2_pre_sync_TIMESTAMP.txt     ← Pre-sync backup
└── sw-core2_pre_sync_TIMESTAMP.txt    ← Pre-sync backup

templates/
├── idf_reference_config.txt           ← IDF template
└── core_reference_config.txt          ← Core template
```

## Workflow

```
1. Pull reference config:     make sync-idf
2. Review config:             cat backups/zyxel/idf1_reference_latest.txt
3. Connect to target:         ssh admin@172.19.1.18
4. Apply configuration:       (manual via CLI or config upload)
5. Verify:                    show vlan; show interface status
6. Test connectivity:         ansible sw-idf2.disconet.work -m ping
```

## Verification Commands (on switch)

```
show vlan                    # Verify VLANs match reference
show interface status        # Check port status
show spanning-tree           # Verify STP (core switches)
show trunk                   # Check trunk/LAG config
show running-config          # Full config review
write memory                 # Save changes
```

## Rollback

If something goes wrong:

```bash
# Find the backup
ls -lt backups/zyxel/sw-idf2_pre_sync_*

# Apply via switch CLI
copy tftp://server/sw-idf2_pre_sync_TIMESTAMP.txt running-config
write memory
```

## Important Notes

- ⚠️  **Always review** reference config before applying
- ⚠️  **Test on one switch** before applying to all
- ⚠️  **Backup first** - sync playbooks create automatic backups
- ⚠️  **Manual application** - playbooks do NOT auto-apply configs
- ⚠️  **STP priority** - Core1=4096 (root), Core2=8192 (backup)
- ⚠️  **Management IPs** - Must be changed per switch
- ⚠️  **Hostnames** - Must be changed per switch

## Configuration Differences by Switch

### IDF Switches
- ✅ Identical: VLANs, port configs, trunk settings
- ⚠️  Different: Management IP, hostname

### Core Switches  
- ✅ Identical: VLANs, port configs, trunk settings
- ⚠️  Different: Management IP, hostname, STP priority

## Support

See full documentation: `SWITCH_SYNC_GUIDE.md`

