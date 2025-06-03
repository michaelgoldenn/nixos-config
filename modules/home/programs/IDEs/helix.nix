{
  flake,
  ...
}: let
  inherit (flake) config inputs;
in {
  programs.helix = {
    enable = true;
    languages = builtins.fromTOML (builtins.readFile ./helix-config/languages.toml);
    settings = {
  keys.normal = {
    "A-k" = ["goto_line_end" "extend_line_below" "delete_selection" "move_line_up" "paste_before"];
    "A-j" = ["goto_line_end" "extend_line_below" "delete_selection" "paste_after"];
  };
  keys.select = {
    "A-k" = ["goto_line_end" "extend_line_below" "delete_selection" "move_line_up" "paste_before" "select_mode"];
    "A-j" = ["goto_line_end" "extend_line_below" "delete_selection" "paste_after" "select_mode"];
  };
};
  };
}
