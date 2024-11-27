{ ... }:
{
  services.copyq = {
    enable = true;
  };
  home.file.".config/copyq/copyq.conf".text = ''
    [Options]
    maxitems=2000
    tabs=&clipboard
    always_on_top=true
    confirm_exit=false
    close_on_unfocus=true
    activate_pastes=false
    disable_tray=false
  '';
}