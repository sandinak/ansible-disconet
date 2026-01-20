# Disconet Ansible Infrastructure Makefile
SHELL := /bin/bash
VENV_DIR := .venv
PYTHON := python3
PIP := $(VENV_DIR)/bin/pip
ANSIBLE := $(VENV_DIR)/bin/ansible
ANSIBLE_PLAYBOOK := $(VENV_DIR)/bin/ansible-playbook
ANSIBLE_GALAXY := $(VENV_DIR)/bin/ansible-galaxy
ANSIBLE_LINT := $(VENV_DIR)/bin/ansible-lint

.PHONY: all venv deps collections install-zyxel-collection install-wap-collection install-local-collections lint test clean check help ping pull pull-pfsense pull-zyxel pull-proxmox sync-idf sync-core sync-all sync-waps

# Default target
all: venv deps collections install-local-collections

# Create virtual environment
$(VENV_DIR)/bin/activate:
	@echo "Creating virtual environment..."
	$(PYTHON) -m venv $(VENV_DIR)
	$(PIP) install --upgrade pip

venv: $(VENV_DIR)/bin/activate

# Install Python dependencies
deps: venv
	@echo "Installing Python dependencies..."
	$(PIP) install -r requirements.txt
	@touch $(VENV_DIR)/.deps_installed

# Install Ansible collections
collections: deps
	@echo "Installing Ansible collections..."
	$(ANSIBLE_GALAXY) collection install -r requirements.yml --force
	@touch $(VENV_DIR)/.collections_installed

# Install Zyxel collection from local ansible-zyxel repository
install-zyxel-collection: deps
	@echo "Installing network.zyxel collection from local repository..."
	@if [ -d "../ansible-zyxel" ]; then \
		cd ../ansible-zyxel && \
		$(CURDIR)/$(ANSIBLE_GALAXY) collection build --force && \
		$(CURDIR)/$(ANSIBLE_GALAXY) collection install network-zyxel-*.tar.gz --force; \
	else \
		echo "ERROR: ansible-zyxel repository not found at ../ansible-zyxel"; \
		echo "Clone it with: git clone git@github.com:sandinak/ansible-zyxel.git ../ansible-zyxel"; \
		exit 1; \
	fi

# Install Netgear WAP collection from local ansible-netgear-wap repository
install-wap-collection: deps
	@echo "Installing sandinak.netgear_wap collection from local repository..."
	@if [ -d "../ansible-netgear-wap" ]; then \
		cd ../ansible-netgear-wap && \
		$(CURDIR)/$(ANSIBLE_GALAXY) collection build --force && \
		$(CURDIR)/$(ANSIBLE_GALAXY) collection install sandinak-netgear_wap-*.tar.gz --force; \
	else \
		echo "ERROR: ansible-netgear-wap repository not found at ../ansible-netgear-wap"; \
		echo "Clone it with: git clone git@github.com:sandinak/ansible-netgear-wap.git ../ansible-netgear-wap"; \
		exit 1; \
	fi

# Install all local collections (zyxel + netgear-wap)
install-local-collections: install-zyxel-collection install-wap-collection
	@echo "All local collections installed."

# Lint playbooks and roles
lint: deps
	@echo "Linting Ansible code..."
	$(ANSIBLE_LINT) playbooks/ roles/

# Syntax check all playbooks
check: deps
	@echo "Checking playbook syntax..."
	$(ANSIBLE_PLAYBOOK) --syntax-check playbooks/*.yml

# Test connectivity to all hosts
ping: deps
	@echo "Testing connectivity..."
	$(ANSIBLE) all -m ping

# Run specific playbook (usage: make play PLAYBOOK=site.yml)
play: deps collections
ifdef PLAYBOOK
	$(ANSIBLE_PLAYBOOK) playbooks/$(PLAYBOOK)
else
	@echo "Usage: make play PLAYBOOK=<playbook.yml>"
endif

# Deploy to specific device type
pfsense: deps collections
	$(ANSIBLE_PLAYBOOK) playbooks/pfsense.yml

zyxel: deps collections
	$(ANSIBLE_PLAYBOOK) playbooks/zyxel.yml

proxmox: deps collections
	$(ANSIBLE_PLAYBOOK) playbooks/proxmox.yml

# Deploy everything
site: deps collections
	$(ANSIBLE_PLAYBOOK) playbooks/site.yml

# Pull configurations from devices (backup + update inventory)
pull: deps collections
	@echo "Pulling configurations from all devices..."
	$(ANSIBLE_PLAYBOOK) playbooks/pull_configs.yml

pull-pfsense: deps collections
	@echo "Pulling pfSense configurations..."
	$(ANSIBLE_PLAYBOOK) playbooks/backup/pull_pfsense.yml

pull-zyxel: deps collections
	@echo "Pulling Zyxel switch configurations..."
	$(ANSIBLE_PLAYBOOK) playbooks/backup/pull_zyxel.yml

pull-proxmox: deps collections
	@echo "Pulling Proxmox configurations..."
	$(ANSIBLE_PLAYBOOK) playbooks/backup/pull_proxmox.yml

# Apply IDF template to switches
idf-deploy: deps collections
	@echo "Deploying IDF switch template..."
	$(ANSIBLE_PLAYBOOK) playbooks/zyxel.yml --limit idf_switches

# Sync switch configurations (pull from reference switches)
sync-idf: deps collections
	@echo "Syncing IDF switch configurations from sw-idf1..."
	$(ANSIBLE_PLAYBOOK) playbooks/sync_idf_switches.yml

sync-core: deps collections
	@echo "Syncing Core switch configurations from sw-core1..."
	$(ANSIBLE_PLAYBOOK) playbooks/sync_core_switches.yml

sync-all: deps collections
	@echo "Syncing all switch configurations..."
	$(ANSIBLE_PLAYBOOK) playbooks/sync_switches.yml

# Sync WAP configurations (pull from reference WAPs)
sync-waps: deps collections install-wap-collection
	@echo "Syncing WAX210 WAP configurations from wap-pod1..."
	$(ANSIBLE_PLAYBOOK) playbooks/sync_wax210_waps.yml

# Clean up
clean:
	@echo "Cleaning up..."
	rm -rf $(VENV_DIR)
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type f -name "*.retry" -delete

# Help
help:
	@echo "Disconet Ansible Infrastructure"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Setup targets:"
	@echo "  all                        - Setup venv, deps, and collections (default)"
	@echo "  venv                       - Create Python virtual environment"
	@echo "  deps                       - Install Python dependencies"
	@echo "  collections                - Install Ansible collections from Galaxy"
	@echo "  install-zyxel-collection   - Build and install network.zyxel from ../ansible-zyxel"
	@echo "  install-wap-collection     - Build and install sandinak.netgear_wap from ../ansible-netgear-wap"
	@echo "  install-local-collections  - Build and install all local collections"
	@echo ""
	@echo "Validation targets:"
	@echo "  lint         - Lint playbooks and roles"
	@echo "  check        - Syntax check all playbooks"
	@echo "  ping         - Test connectivity to all hosts"
	@echo ""
	@echo "Deployment targets:"
	@echo "  site         - Deploy full site configuration"
	@echo "  pfsense      - Deploy pfSense configuration"
	@echo "  zyxel        - Deploy Zyxel switch configuration"
	@echo "  proxmox      - Deploy Proxmox VM configuration"
	@echo "  play         - Run specific playbook (PLAYBOOK=name.yml)"
	@echo ""
	@echo "Backup/Pull targets:"
	@echo "  pull         - Pull configs from all devices (backup + update inventory)"
	@echo "  pull-pfsense - Pull pfSense configurations"
	@echo "  pull-zyxel   - Pull Zyxel switch configurations"
	@echo "  pull-proxmox - Pull Proxmox configurations"
	@echo ""
	@echo "Switch Sync targets (pull from reference switches):"
	@echo "  sync-idf     - Sync IDF switches from sw-idf1 (reference)"
	@echo "  sync-core    - Sync Core switches from sw-core1 (reference)"
	@echo "  sync-all     - Sync all switch types from reference switches"
	@echo ""
	@echo "WAP Sync targets:"
	@echo "  sync-waps    - Sync WAX210 WAPs from wap-pod1 (reference)"
	@echo ""
	@echo "Template targets:"
	@echo "  idf-deploy   - Deploy IDF switch template to all IDF switches"
	@echo ""
	@echo "Maintenance:"
	@echo "  clean        - Remove venv and temp files"
	@echo "  help         - Show this help"

