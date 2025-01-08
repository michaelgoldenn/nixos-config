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

# same thing as run, but git pulls and pushes as well
alias fr := full-rebuild
alias full-run := full-rebuild
[group('Main')]
full-rebuild:
  ./bash/full-rebuild

# Open the sops file for adding or editing keys
[group('dev')]
sops:
  nix-shell -p sops --run "sops /etc/nixos/secrets/secrets.yaml"

[group('Main')]
gc:
  nix-store --gc

[group('Main')]
clean:
  nh clean all -k 20
