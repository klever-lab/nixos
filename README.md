# NixOS Configuration for Klever Lab Machines

This repository provides tools to bootstrap, manage, and install NixOS configurations across Klever Lab infrastructure. It supports a range of deployment environments, including cloud servers and local hardware.

## Features

1. Bootstrapping for cloud servers
2. Bootstrapping for local machines with NixOS pre-installed
3. Live installer ISO generation for NixOS installation with custom configuration
4. Continuous NixOS Configuration

## Getting Started

### 1. Cloud Bootstrapping

**Requirements:**

* SSH access to a cloud server running any Linux OS

**Steps:**

1. Connect to the server.
2. Run `nixosanywhere.sh`.
3. Follow the on-screen instructions.

### 2. Local Bootstrapping

**Requirements:**

* A machine with NixOS already installed

**Steps:**

1. Run `bootstrap.sh` locally.
2. This will:

   * Delete the existing configuration.
   * Apply Klever Lab's setup.
   * Rebuild the system.

### 3. Installation ISO Generation

**Status:** Work in progress

**Goal:**

* Build a live boot/installer ISO pre-configured with Klever Lab's NixOS setup.

### 4. Continuous NixOS Configuration

**Mechanism:**

* A pre-installed systemd service runs every 5 minutes and checks this repository for changes not present locally. It rebuilds the system if new changes are detected.

## Secret Management

**Approach:**

We use `sops-nix` in combination with `age` to manage encrypted secrets within the GitHub repository.

**How it works:**

* Secrets are decrypted using a primary age key that must be present at `/root/.config/sops/age/keys.txt`.
* This primary key is encrypted with age and stored in the repo as one of two files:

  * `sops-nix_primary_key.age_password`
  * `sops-nix_primary_key.age_yubikey`
* Only one of these is needed to decrypt the primary key.

**Remote Bootstrapping:**

* The decrypted primary key can be placed locally on the initiating machine.
* `nixos-anywhere` supports passing and copying this key over with a flag during setup.

**Local / ISO:**

* On local installs or ISO-based setups, either of the two encrypted key files can be used.
* The user can:

  * Use a **YubiKey** to decrypt `sops-nix_primary_key.age_yubikey`.
  * Or use a **password** to decrypt `sops-nix_primary_key.age_password`.
* Once decrypted, the primary key is placed with the `place_age_keys.sh` script, enabling `sops-nix` to use it during system builds.
