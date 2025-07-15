{ ... }:
{
  programs.btop = {
    enable = true;
    extraConfig = "update_ms = 500";
  };
}
