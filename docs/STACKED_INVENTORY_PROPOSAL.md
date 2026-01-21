# Stacked Inventory Proposal

> **Status**: Proposed for future implementation (post-DistrictCon 2026)
> **Created**: 2026-01-19
> **Author**: Infrastructure Team

## Overview

This document proposes migrating from the current single-inventory structure to a
**stacked inventory** approach for better separation of concerns and event-based
configuration management.

## Current Approach: Single Inventory with Group Vars

```
inventory/
├── hosts.yml                      # All hosts defined here
├── group_vars/
│   ├── all/
│   │   ├── all.yml                # Global base (disconet.*)
│   │   ├── networks.yml           # VLAN definitions
│   │   └── vault.yml              # Secrets
│   ├── idf_switches.yml           # Base + Delta merged (Jinja2)
│   ├── core_switches.yml
│   └── wax210.yml
└── host_vars/
    └── <hostname>.yml             # Per-host overrides
```

**How it works**: Inheritance via Ansible's variable precedence (`all` → `group` → `host`)
plus Jinja2 templates that merge `*_switch_delta` with base values into `*_switch_config`.

## Proposed: Stacked Inventory

```
inventory/
├── base/                          # Layer 1: Foundation (rarely changes)
│   ├── hosts.yml                  # Device inventory only
│   └── group_vars/
│       └── all/
│           ├── all.yml            # Global: domain, DNS, NTP
│           ├── networks.yml       # VLAN definitions
│           └── vault.yml          # Secrets
│
├── golden/                        # Layer 2: Golden configs (from reference devices)
│   └── group_vars/
│       ├── idf_switches.yml       # Pulled from sw-idf1
│       ├── core_switches.yml      # Pulled from sw-core1
│       ├── podium_switches.yml    # Pulled from sw-pod1
│       └── wax210.yml             # Pulled from wap-pod1
│
└── event/                         # Layer 3: Event-specific overrides
    ├── group_vars/
    │   ├── wax210.yml             # Temporary SSIDs, settings
    │   └── idf_switches.yml       # Event-specific port configs
    └── host_vars/
        └── <hostname>.yml         # Per-device exceptions
```

**Usage**:
```bash
export ANSIBLE_INVENTORY=inventory/base,inventory/golden,inventory/event
ansible-playbook playbooks/sync_idf_switches.yml
```

## Comparison

| Aspect                  | Current (Single)                | Stacked                              |
|-------------------------|--------------------------------|--------------------------------------|
| File organization       | Flat - all in one place        | Layered by concern                   |
| Inheritance visibility  | Hidden in Jinja2 templates     | Explicit via directory order         |
| Golden config isolation | Mixed with computed vars       | Read-only after pulls                |
| Event-specific changes  | Edit group_vars directly       | Isolated in event/ layer             |
| Rollback complexity     | Git revert on mixed files      | Delete/swap event/ directory         |
| Diff clarity            | Hard to see "what's custom"    | `diff golden/ event/`                |
| Setup complexity        | Simpler                        | More directories to manage           |

## Benefits of Stacked Inventory

1. **Clean separation**: Golden configs never modified during events
2. **Easy rollback**: Delete `event/` to return to baseline
3. **Audit trail**: All event customizations in one place
4. **Multi-year support**: Archive `event-2026/`, create `event-2027/`
5. **Reduced merge conflicts**: Teams work in different directories
6. **CI/CD friendly**: Easy to validate "only event/ changed"

## Proposed Workflow

### Pre-Event Setup
```bash
# 1. Pull fresh golden configs from reference devices
make pull-golden-all
# Writes to: inventory/golden/group_vars/

# 2. Create event overlay from template
cp -r inventory/event-template inventory/event

# 3. Configure event-specific settings
vim inventory/event/group_vars/wax210.yml  # Add event SSIDs
```

### During Event
```bash
# All changes go to event/ only
vim inventory/event/host_vars/sw-idf3.yml  # Emergency port change

# Golden configs remain untouched
```

### Post-Event
```bash
# Archive and clean up
mv inventory/event inventory/archive/event-2026
git add inventory/archive/event-2026
git commit -m "Archive DistrictCon 2026 event configs"
```

## Migration Steps (Future)

1. Create `inventory/base/` and move `hosts.yml` + `all/` there
2. Create `inventory/golden/` and move device-type group_vars there
3. Update `pull_golden_config.yml` to write to `inventory/golden/`
4. Create `inventory/event-template/` with empty structure
5. Update `ansible.cfg` to use stacked inventory path
6. Update Makefile targets for new structure
7. Document new workflow in README.md

## Configuration Changes Required

### ansible.cfg
```ini
[defaults]
# Current
inventory = inventory

# Stacked (use environment variable for flexibility)
# inventory = inventory/base,inventory/golden,inventory/event
```

### Makefile additions
```makefile
# Create event overlay
event-init:
    cp -r inventory/event-template inventory/event
    @echo "Event overlay created. Edit inventory/event/ for customizations."

# Archive event configs
event-archive:
    @read -p "Event name (e.g., districtcon-2026): " name; \
    mv inventory/event inventory/archive/$$name
    @echo "Event archived. Run 'event-init' before next event."
```

## Decision Log

- **2026-01-19**: Documented proposal, deferred to post-DistrictCon 2026
- Current Base + Delta model working well for single-event use case
- Will revisit if multi-year config management becomes painful

## References

- [Ansible Inventory Documentation](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html)
- [Using Multiple Inventory Sources](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#using-multiple-inventory-sources)

