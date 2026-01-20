# Ansible Vault Setup Guide

This project uses Ansible Vault to securely store sensitive credentials like passwords and API keys.

## Overview

- **Encrypted vault files**: Stored in `inventory/group_vars/*/vault.yml` (committed to git)
- **Vault password**: Stored in `.vault_pass` (NOT committed to git)
- **Variable references**: Stored in `inventory/group_vars/*/vars.yml`

## Current Vault Configuration

### Zyxel Switches

**Vault file**: `inventory/group_vars/zyxel/vault.yml` (encrypted)
**Variables file**: `inventory/group_vars/zyxel/vars.yml`

Credentials:
- Username: `admin`
- Password: Stored as `vault_zyxel_password` in vault.yml

## Vault Password

The vault password is: `9Qjm9CupSzswkzpkpanxiJoJIELnW3SRJ6d42JxVxRE=`

This password is stored in `.vault_pass` and configured in `ansible.cfg`:
```ini
vault_password_file = .vault_pass
```

**⚠️ IMPORTANT**: The `.vault_pass` file is in `.gitignore` and should NEVER be committed to git.

## Working with Vault Files

### View encrypted vault file
```bash
ansible-vault view inventory/group_vars/zyxel/vault.yml
```

### Edit encrypted vault file
```bash
ansible-vault edit inventory/group_vars/zyxel/vault.yml
```

### Create a new vault file
```bash
ansible-vault create inventory/group_vars/newgroup/vault.yml
```

### Encrypt an existing file
```bash
ansible-vault encrypt inventory/group_vars/newgroup/secrets.yml
```

### Decrypt a vault file (temporarily)
```bash
ansible-vault decrypt inventory/group_vars/zyxel/vault.yml
# Edit the file
ansible-vault encrypt inventory/group_vars/zyxel/vault.yml
```

### Change vault password
```bash
ansible-vault rekey inventory/group_vars/zyxel/vault.yml
# Update .vault_pass with new password
```

## Running Playbooks with Vault

Since `vault_password_file` is configured in `ansible.cfg`, playbooks automatically decrypt vault files:

```bash
# No extra flags needed
ansible-playbook playbooks/sync_core_switches.yml

# Or with the alias
ap playbooks/sync_core_switches.yml
```

### Without vault_password_file configured

If you don't have `.vault_pass` configured, you can:

```bash
# Prompt for password
ansible-playbook playbooks/sync_core_switches.yml --ask-vault-pass

# Or specify password file
ansible-playbook playbooks/sync_core_switches.yml --vault-password-file /path/to/password
```

## Adding New Credentials

### For a new device group

1. **Create vault file**:
   ```bash
   ansible-vault create inventory/group_vars/newgroup/vault.yml
   ```

2. **Add encrypted variables** (in the editor that opens):
   ```yaml
   ---
   vault_newgroup_password: secretpassword123
   vault_newgroup_api_key: abc123xyz
   ```

3. **Create vars file** to reference vault:
   ```bash
   cat > inventory/group_vars/newgroup/vars.yml << 'EOF'
   ---
   ansible_user: admin
   ansible_password: "{{ vault_newgroup_password }}"
   api_key: "{{ vault_newgroup_api_key }}"
   EOF
   ```

4. **Commit the vault file** (it's encrypted):
   ```bash
   git add inventory/group_vars/newgroup/vault.yml
   git add inventory/group_vars/newgroup/vars.yml
   git commit -m "Add credentials for newgroup"
   ```

## Security Best Practices

### ✅ DO:
- Commit encrypted vault.yml files to git
- Use strong vault passwords
- Store vault password in `.vault_pass` locally
- Share vault password securely (1Password, LastPass, etc.)
- Use different vault passwords for different environments (dev/staging/prod)
- Regularly rotate passwords and rekey vaults

### ❌ DON'T:
- Commit `.vault_pass` to git
- Share vault passwords in plain text (email, Slack, etc.)
- Store unencrypted passwords in inventory files
- Use weak vault passwords
- Commit decrypted vault files

## Team Setup

When a new team member joins:

1. **Clone the repository**:
   ```bash
   git clone git@github.com:sandinak/ansible-disconet.git
   cd ansible-disconet
   ```

2. **Create vault password file**:
   ```bash
   echo "9Qjm9CupSzswkzpkpanxiJoJIELnW3SRJ6d42JxVxRE=" > .vault_pass
   chmod 600 .vault_pass
   ```

3. **Verify vault access**:
   ```bash
   ansible-vault view inventory/group_vars/zyxel/vault.yml
   ```

4. **Setup environment**:
   ```bash
   source sourceme
   ```

## Troubleshooting

### Error: "Decryption failed"
- Check that `.vault_pass` contains the correct password
- Verify the vault file is properly encrypted: `head -1 inventory/group_vars/zyxel/vault.yml` should show `$ANSIBLE_VAULT;1.1;AES256`

### Error: "vault password file not found"
- Create `.vault_pass` with the vault password
- Or use `--ask-vault-pass` flag

### Variables not resolving
- Check that vars.yml references the vault variable correctly: `"{{ vault_variable_name }}"`
- Verify the vault file contains the variable

### Accidentally committed .vault_pass
```bash
# Remove from git history
git rm --cached .vault_pass
git commit -m "Remove vault password file"

# Rotate the vault password immediately
ansible-vault rekey inventory/group_vars/*/vault.yml
```

## Current Vault Contents

### inventory/group_vars/zyxel/vault.yml
```yaml
---
# Zyxel Switch Vault - Encrypted Credentials
vault_zyxel_password: r0llerDizk0Bawtms
```

Referenced in `inventory/group_vars/zyxel/vars.yml`:
```yaml
---
ansible_user: admin
ansible_password: "{{ vault_zyxel_password }}"
```

