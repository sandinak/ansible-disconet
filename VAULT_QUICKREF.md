# Ansible Vault Quick Reference

## Vault Password
```
9Qjm9CupSzswkzpkpanxiJoJIELnW3SRJ6d42JxVxRE=
```
Stored in: `.vault_pass` (not committed to git)

## Common Commands

| Task | Command |
|------|---------|
| View vault | `ansible-vault view inventory/group_vars/zyxel/vault.yml` |
| Edit vault | `ansible-vault edit inventory/group_vars/zyxel/vault.yml` |
| Create vault | `ansible-vault create path/to/vault.yml` |
| Encrypt file | `ansible-vault encrypt path/to/file.yml` |
| Decrypt file | `ansible-vault decrypt path/to/file.yml` |
| Change password | `ansible-vault rekey path/to/vault.yml` |

## Current Vaults

### Zyxel Switches
- **File**: `inventory/group_vars/zyxel/vault.yml`
- **Username**: `admin`
- **Password variable**: `vault_zyxel_password`
- **Value**: `***REMOVED***`

## Running Playbooks

Vault is automatically decrypted (configured in `ansible.cfg`):

```bash
# Just run normally
ansible-playbook playbooks/sync_core_switches.yml
ap playbooks/sync_core_switches.yml
make sync-core
```

## File Structure

```
inventory/group_vars/zyxel/
├── vault.yml          # Encrypted credentials (COMMIT THIS)
└── vars.yml           # References to vault variables (COMMIT THIS)

.vault_pass            # Vault password (DO NOT COMMIT)
```

## Setup for New Team Member

```bash
# 1. Clone repo
git clone git@github.com:sandinak/ansible-disconet.git
cd ansible-disconet

# 2. Create vault password file
echo "9Qjm9CupSzswkzpkpanxiJoJIELnW3SRJ6d42JxVxRE=" > .vault_pass
chmod 600 .vault_pass

# 3. Test vault access
ansible-vault view inventory/group_vars/zyxel/vault.yml

# 4. Setup environment
source sourceme
```

## Security Notes

✅ **DO commit**: Encrypted vault.yml files  
❌ **DON'T commit**: .vault_pass file  
🔒 **Share password**: Use secure channel (1Password, LastPass, etc.)

