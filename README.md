# ansible-disconet

Ansible infrastructure automation for the Disconet network, managing pfSense firewalls, Zyxel switches, and Proxmox VMs.

## Quick Start

```bash
# Clone the repository
git clone git@github.com:sandinak/ansible-disconet.git
cd ansible-disconet

# Clone the required ansible-zyxel collection repository
git clone git@github.com:sandinak/ansible-zyxel.git ../ansible-zyxel

# Setup environment and install dependencies
make all

# Test connectivity
make ping
```

## Installation

### Prerequisites

- Python 3.8 or higher
- Git
- SSH access to managed devices
- Ansible vault password (for encrypted credentials)

### Setup Steps

1. **Clone repositories**:
   ```bash
   git clone git@github.com:sandinak/ansible-disconet.git
   cd ansible-disconet
   git clone git@github.com:sandinak/ansible-zyxel.git ../ansible-zyxel
   ```

2. **Install dependencies**:
   ```bash
   make all
   ```
   This will:
   - Create a Python virtual environment
   - Install Python dependencies
   - Install Ansible collections from Galaxy
   - Build and install the network.zyxel collection from the local repository

3. **Configure vault password**:
   - Create `.vault_pass` file with your Ansible vault password
   - Or set `ANSIBLE_VAULT_PASSWORD_FILE` environment variable

## Usage

### Common Commands

```bash
# Test connectivity to all devices
make ping

# Deploy full site configuration
make site

# Deploy to specific device types
make pfsense    # Deploy pfSense configuration
make zyxel      # Deploy Zyxel switch configuration
make proxmox    # Deploy Proxmox VM configuration

# Pull configurations from devices (backup)
make pull              # Pull from all devices
make pull-pfsense      # Pull pfSense configs
make pull-zyxel        # Pull Zyxel configs
make pull-proxmox      # Pull Proxmox configs

# Sync switch configurations from reference switches
make sync-idf          # Sync IDF switches from sw-idf1
make sync-core         # Sync core switches from sw-core1
make sync-all          # Sync all switches

# Validation
make lint              # Lint playbooks and roles
make check             # Syntax check playbooks
```

### Running Specific Playbooks

```bash
# Run a specific playbook
make play PLAYBOOK=sync_idf_switches.yml

# Or use ansible-playbook directly
source .venv/bin/activate
ansible-playbook playbooks/sync_idf_switches.yml
```

## Project Structure

```
ansible-disconet/
├── inventory/
│   ├── hosts.yml              # Main inventory file
│   ├── group_vars/            # Group variables
│   └── host_vars/             # Host-specific variables
├── playbooks/
│   ├── site.yml               # Main site playbook
│   ├── pfsense.yml            # pfSense deployment
│   ├── zyxel.yml              # Zyxel switch deployment
│   ├── proxmox.yml            # Proxmox VM deployment
│   ├── sync_idf_switches.yml # Sync IDF switches
│   ├── sync_core_switches.yml# Sync core switches
│   └── backup/                # Backup playbooks
├── roles/
│   ├── zyxel_base/            # Base Zyxel configuration
│   ├── zyxel_vlans/           # VLAN configuration
│   ├── zyxel_ports/           # Port configuration
│   └── zyxel_security/        # Security configuration
├── Makefile                   # Build and deployment automation
├── requirements.txt           # Python dependencies
├── requirements.yml           # Ansible collection dependencies
└── ansible.cfg                # Ansible configuration
```

## Zyxel Collection

This project uses a custom Ansible collection for Zyxel switch management (`network.zyxel`). The collection is maintained in a separate repository and must be installed from the local clone.

### Updating the Zyxel Collection

```bash
# Pull latest changes from ansible-zyxel
cd ../ansible-zyxel
git pull

# Rebuild and reinstall the collection
cd ../ansible-disconet
make install-zyxel-collection
```

## Maintenance

```bash
# Clean up virtual environment and temporary files
make clean

# Reinstall everything
make clean && make all
```

## Help

```bash
# Show all available make targets
make help
```
