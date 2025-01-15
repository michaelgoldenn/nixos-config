{ pkgs, ... }:
{
  programs = {
    bash = {
      enable = true;
      initExtra = ''
        # Custom bash profile goes here
      '';
    };
    nushell = { 
      enable = true;
      # The config.nu can be anywhere you want if you like to edit your Nushell with Nu
      #configFile.source = ./.../config.nu;
      shellAliases = {
        g = "git";
        lg = "lazygit";
        cd = "z";
      };
      extraConfig = let
        config = {
          show_banner = false;
          keybindings = [
            {
              name = "abbr";
              modifier = "control";
              keycode = "space";
              mode = ["emacs" "vi_normal" "vi_insert"];
              event = [
                {
                  send = "menu";
                  name = "abbr_menu";
                }
                {
                  edit = "insertchar";
                  value = " ";
                }
              ];
            }
          ];
          menus = [
            {
              name = "abbr_menu";
              only_buffer_difference = false;
              marker = "👀 ";
              type = {
                layout = "columnar";
                columns = 1;
                col_width = 20;
                col_padding = 2;
              };
              style = {
                text = "green";
                selected_text = "green_reverse";
                description_text = "yellow";
              };
              source = ''|buffer, position|
                scope aliases
                | where name == $buffer
                | each { |elt| {value: $elt.expansion }}'';
            }
          ];
        };
      in ''
        $env.config = ${builtins.toJSON config}
      '';
   };  
    carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
    zoxide = {
      enable = true;
      enableNushellIntegration = true; 
    };
  };
  home.sessionVariables = {
    NIX_BUILD_SHELL = "${pkgs.nushell}/bin/nu";
  };
}