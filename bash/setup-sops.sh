mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'