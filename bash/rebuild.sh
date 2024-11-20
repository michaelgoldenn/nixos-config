set -e
pushd /etc/nixos/
git diff -U0 *.nix
echo "NixOS Rebuilding..."
nix run
gen=$(nixos-rebuild list-generations | grep current)
git commit -am "$gen"
popd
