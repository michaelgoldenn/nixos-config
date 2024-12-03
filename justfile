# Like GNU `make`, but `just` rustier.
# https://just.systems/
# run `just` from this directory to see available commands

# Default command when 'just' is run without arguments
default:
  @just --list

# Update nix flake
[group('Main')]
update:
  nix flake update

# Lint nix files
[group('dev')]
lint:
  nix fmt

# Check nix flake
[group('dev')]
check:
  nix flake check

# Manually enter dev shell
[group('dev')]
dev:
  nix develop

# Rebuild and switch to new configuration
alias r := run
alias rebuild := run
[group('Main')]
run:
  ./bash/rebuild

# Open the sops file for adding or editing keys
[group('dev')]
sops:
  nix-shell -p sops --run "sops /etc/nixos/secrets/secrets.yaml"
