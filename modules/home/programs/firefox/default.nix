# A module that automatically imports .nix files and subdirectories in the parent folder
{
  imports =
    with builtins;
    map
      (fn: ./${fn})
      (filter
        (fn:
          let
            type = (readDir ./.).${fn};
          in
          (type == "directory") || (stringLength fn >= 4 && substring (stringLength fn - 4) 4 fn == ".nix" 
          && fn != "default.nix" && fn != "shyfox_import.nix"))
        (attrNames (readDir ./.)));
}