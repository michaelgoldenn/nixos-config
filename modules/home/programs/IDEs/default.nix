# A module that automatically imports .nix files in the parent folder (excluding subdirectories)
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
          type == "regular" && stringLength fn >= 4 && substring (stringLength fn - 4) 4 fn == ".nix" 
          && fn != "default.nix")
        (attrNames (readDir ./.)));
}