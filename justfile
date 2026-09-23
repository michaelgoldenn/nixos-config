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

# Activate the configuration
alias r := run
alias switch := run
[group('Main')]
run:
  nh os switch ./
  # A rebuild resets the theme to `theme.name` in the flake, so re-apply whatever
  # was last picked with `theme set`. Fails harmlessly if nothing was ever picked.
  -theme restore

# Switch theme + wallpaper live, no rebuild. Omit the name for a fuzzy picker.
[group('Main')]
theme name='':
  theme {{ if name == '' { '' } else { 'set ' + name } }}

# Open the sops file for adding or editing keys
[group('dev')]
sops:
  nix-shell -p sops --run "sops /etc/nixos/modules/secrets/secrets.yaml"
