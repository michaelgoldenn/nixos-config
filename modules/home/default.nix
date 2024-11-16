# A module that automatically imports everything else in the parent folder.
{
  imports =
    with builtins;
    let
      files = attrNames (readDir ./.);
      filtered = filter (fn: fn != "default.nix") files;
    in
    builtins.trace "Found files: ${toString filtered}"
    map
      (fn: ./${fn})
      filtered;
}