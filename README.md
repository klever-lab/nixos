# NixOS Configuration for Klever Lab Machines

This repository provides tools to bootstrap, manage, and install NixOS configurations across Klever Lab infrastructure. It supports deployment on both cloud servers and local machines via a custom installer ISO.

## Features

1. Bootstrapping into NixOS for cloud servers
2. Installation ISO with built-in install script
3. Continuous NixOS configuration updates

## Getting Started

### 1. Cloud Bootstrapping

**Requirements:**

* SSH access to a cloud server running any Linux OS

**Steps:**

1. Run `nixosanywhere.sh` locally.
2. Follow the on-screen instructions to bootstrap the remote server into NixOS.

### 2. Installation ISO

* Download the prebuilt ISO or build it yourself.
* The ISO is a live boot environment with a custom NixOS configuration and an install script.
* This is the only supported method for configuring local machines.

### 3. Continuous NixOS Configuration

* A systemd service included in the base configuration runs every 5 minutes.
* It checks this repository for updates not yet present on the system.
* If changes are found, it automatically pulls the latest version and rebuilds the system configuration.

## Secret Management

**Approach:**

We use `sops-nix` in combination with `age` to manage encrypted secrets stored in the GitHub repository.

**How it works:**

* During system builds, secrets are decrypted using a primary `age` key located at `/root/.config/sops/age/keys.txt`.
* This key is not stored directly. Instead, it’s encrypted and committed to the repository in two forms:

  * `sops-nix_primary_key.age_password`
  * `sops-nix_primary_key.age_yubikey`
* Both contain the same key; either can be used to decrypt it.

**Remote Bootstrapping:**

* The `remote_bootstrap.sh` script places the decrypted primary key in a local file.
* It uses a flag to securely copy the key to the target machine during setup.

**ISO:**

* The ISO includes the encrypted key files. The installer script will handle everything.
* The user can:

  * Use a **YubiKey** to decrypt `sops-nix_primary_key.age_yubikey`.
  * Or use a **password** to decrypt `sops-nix_primary_key.age_password`.
* Once decrypted, the key is placed in the correct path so `sops-nix` can access secrets during system builds.

