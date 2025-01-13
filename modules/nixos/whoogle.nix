{ lib
, config
, pkgs
, ...
}:
with lib;
let
  app = "whoogle";
  image = "ghcr.io/benbusby/whoogle-search:0.9.1@sha256:f3649f5652495deed4ea228a13bdb54dce480af39ba1e48f11fbab541b68e858";
  user = "927"; #string
  group = "927"; #string
  port = 5000; #int
  cfg = config.mySystem.services.${app};
  colors = config.lib.stylix.colors;
  appFolder = "/var/lib/${app}";
  # persistentFolder = "${config.mySystem.persistentFolder}/var/lib/${appFolder}";
in
{
  options.mySystem.services.${app} =
    {
      enable = mkEnableOption "${app}";
      #addToHomepage = mkEnableOption "Add ${app} to homepage" // { default = true; };
    };

  config = mkIf cfg.enable {

    virtualisation.oci-containers.containers.${app} = {
      image = "${image}";
      user = "${user}:${group}";
      ports = [ "5000:5000" ]; # expose port
      environment = {
        # All variables listed here: https://github.com/benbusby/whoogle-search#environment-variables
        TZ = "${config.time.timeZone}";
        /*
        # Alternate hosts for specific websites
        WHOOGLE_ALT_TW = "nitter.${config.networking.domain}";
        WHOOGLE_ALT_YT = "invidious.${config.networking.domain}";
        WHOOGLE_ALT_IG = "imginn.com";
        WHOOGLE_ALT_RD = "redlib.${config.networking.domain}";
        WHOOGLE_ALT_MD = "scribe.${config.networking.domain}";
        WHOOGLE_ALT_TL = "";
        WHOOGLE_ALT_IMG = "bibliogram.art";
        WHOOGLE_ALT_IMDB = "";
        WHOOGLE_ALT_WIKI = "";
        WHOOGLE_ALT_QUORA = "";
        */
        WHOOGLE_CONFIG_ALTS = "0"; # set to `1` to enable alternate social medias
        WHOOGLE_CONFIG_THEME = "system";
        WHOOGLE_CONFIG_URL = "https://whoogle.${config.networking.domain}";
        WHOOGLE_CONFIG_GET_ONLY = "1";
        WHOOGLE_CONFIG_COUNTRY = "AU";
        WHOOGLE_CONFIG_VIEW_IMAGE = "1";
        WHOOGLE_CONFIG_DISABLE = "1";
        # Automatically uses the colors from stylix
        WHOOGLE_CONFIG_STYLE = ":root{"
          + "--whoogle-logo:${colors.base05};"
          + "--whoogle-page-bg:${colors.base00};"
          + "--whoogle-element-bg:${colors.base02};"
          + "--whoogle-text:${colors.base05};"
          + "--whoogle-contrast-text:${colors.base04};"
          + "--whoogle-secondary-text:${colors.base03};"
          + "--whoogle-result-bg:${colors.base01};"
          + "--whoogle-result-title:${colors.base0D};"
          + "--whoogle-result-url:${colors.base09};"
          + "--whoogle-result-visited:${colors.base08};"
          # Light theme colors (you might want to adjust these)
          + "--whoogle-dark-logo:${colors.base05};"
          + "--whoogle-dark-page-bg:${colors.base00};"
          + "--whoogle-dark-element-bg:${colors.base02};"
          + "--whoogle-dark-text:${colors.base05};"
          + "--whoogle-dark-contrast-text:${colors.base04};"
          + "--whoogle-dark-secondary-text:${colors.base03};"
          + "--whoogle-dark-result-bg:${colors.base01};"
          + "--whoogle-dark-result-title:${colors.base0D};"
          + "--whoogle-dark-result-url:${colors.base09};"
          + "--whoogle-dark-result-visited:${colors.base08};"
          + "}"
          # Whoogle logo colors
          + "#whoogle-w{fill:${colors.base0D};}"
          + "#whoogle-h{fill:${colors.base08};}"
          + "#whoogle-o-1{fill:${colors.base0A};}"
          + "#whoogle-o-2{fill:${colors.base0D};}"
          + "#whoogle-g{fill:${colors.base0B};}"
          + "#whoogle-l{fill:${colors.base08};}"
          + "#whoogle-e{fill:${colors.base0A};}";
      };
    };

    services.nginx.virtualHosts."${app}.${config.networking.domain}" = {
      # useACMEHost = config.networking.domain;
      # forceSSL = true;
      locations."^~ /" = {
        proxyPass = "http://${app}:${builtins.toString port}";
        extraConfig = "resolver 10.88.0.1;";
      };
    };
  };
}