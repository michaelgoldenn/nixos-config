# overlays/default.nix
{ flake, ... }:
self: super:
# Apply the millennium overlay
flake.inputs.millennium.overlays.default self super
