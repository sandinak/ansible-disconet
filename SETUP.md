# Setup Guide for ansible-disconet

This guide walks you through setting up the ansible-disconet infrastructure automation.

## Prerequisites

Before you begin, ensure you have:

- **Python 3.8+** installed
- **Git** installed
- **SSH access** to managed devices
- **Ansible vault password** (contact the team if you don't have it)

## Step-by-Step Setup

### 1. Clone the Repositories

```bash
# Clone the main ansible-disconet repository
cd ~/git  # or your preferred directory
git clone git@github.com:sandinak/ansible-disconet.git
cd ansible-disconet

# Clone the ansible-zyxel collection repository (required dependency)
git clone git@github.com:sandinak/ansible-zyxel.git ../ansible-zyxel
```

**Important**: The `ansible-zyxel` repository must be cloned as a sibling directory to `ansible-disconet`.

### 2. Install Dependencies

```bash
# Run the automated setup (creates venv, installs dependencies, builds collections)
make all
```

This command will:
1. Create a Python virtual environment in `.venv/`
2. Install Python packages from `requirements.txt`
3. Install Ansible collections from Ansible Galaxy
4. Build and install the `network.zyxel` collection from `../ansible-zyxel`

### 3. Configure Vault Password

Create a `.vault_pass` file in the repository root:

```bash
echo "your-vault-password-here" > .vault_pass
chmod 600 .vault_pass
```

Alternatively, set the environment variable:

```bash
export ANSIBLE_VAULT_PASSWORD_FILE=~/.ansible_vault_pass
```

### 4. Verify Installation

Test connectivity to all managed devices:

```bash
make ping
```

You should see successful responses from all devices in the inventory.

### 5. Test a Simple Playbook

Try pulling configurations from devices:

```bash
make pull-zyxel
```

## Updating the Environment

### Update Python Dependencies

```bash
source .venv/bin/activate
pip install -r requirements.txt --upgrade
```

### Update Ansible Collections

```bash
make collections
```

### Update the Zyxel Collection

When the `ansible-zyxel` repository is updated:

```bash
# Pull latest changes
cd ../ansible-zyxel
git pull

# Rebuild and reinstall
cd ../ansible-disconet
make install-zyxel-collection
```

## Troubleshooting

### Collection Not Found

If you get errors about `network.zyxel` not being found:

```bash
# Verify the collection is installed
source .venv/bin/activate
ansible-galaxy collection list network.zyxel

# If not found, reinstall
make install-zyxel-collection
```

### Connection Issues

If you can't connect to devices:

1. Verify SSH access: `ssh admin@sw-idf1.disconet.work`
2. Check inventory file: `inventory/hosts.yml`
3. Verify vault password is correct
4. Check network connectivity

### Python Virtual Environment Issues

If the virtual environment is corrupted:

```bash
make clean
make all
```

## Next Steps

- Review the [README.md](README.md) for usage examples
- Explore playbooks in `playbooks/`
- Review roles in `roles/`
- Run `make help` to see all available commands

## Getting Help

- Check the documentation in `docs/`
- Review playbook comments and role README files
- Contact the infrastructure team

