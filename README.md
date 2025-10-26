<!-- Quality & Security Overview -->
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_infra&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_infra)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_infra&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_infra)
[![Known Vulnerabilities](https://snyk.io/test/github/CalebSargeant/infra/badge.svg)](https://snyk.io/test/github/CalebSargeant/infra)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_infra&metric=sqale_rating)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_infra)
[![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_infra&metric=ncloc)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_infra)

# Monolithic Deployments

Embracing the simplicity of unified infrastructure management in a fragmented world.

## Overview

This repository contains a comprehensive infrastructure-as-code solution for managing Kubernetes clusters, Helm charts, Terraform modules, and Ansible playbooks. It's designed for running a complete home lab or small-scale production environment on a Raspberry Pi 5 or similar hardware.

## Quick Start

### Prerequisites

Install the required tools (macOS):

```bash
brew install ansible terraform terragrunt helm kubectl docker
```

### Bootstrap a Kubernetes Cluster

```bash
cd ansible
ansible-playbook -i hosts pi-k3s-bootstrap.yml
```

### Deploy Applications

```bash
cd kubernetes
terragrunt run-all apply
```

## 📚 Documentation

▶ **Full documentation:** https://calebsargeant.github.io/infra/

The complete documentation includes:

- **Getting Started** - Prerequisites and setup guides
- **Guides** - Step-by-step tutorials for common tasks
- **Operations** - Operational procedures (NFS, auto-updates, etc.)
- **Reference** - Technical documentation for Helm charts and Terraform modules

## Key Features

- 🎯 **Single-node Kubernetes** on Raspberry Pi with k3s
- 🚀 **Helm charts** for 20+ applications
- 📁 **NFS server** for shared storage
- 🔄 **Auto-update system** with Slack notifications
- ☁️ **Terraform modules** for cloud infrastructure
- 🛡️ **Pre-commit hooks** for code quality

## Contributing

Contributions are welcome! Please read the contributing guidelines in the documentation.

## Licence

This project is licenced under the MIT Licence - see the [LICENSE](LICENSE) file for details.
