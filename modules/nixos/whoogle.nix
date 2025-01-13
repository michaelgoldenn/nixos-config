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
        WHOOGLE_CONFIG_ALTS = "0";
        WHOOGLE_CONFIG_THEME = "system";
        WHOOGLE_CONFIG_URL = "https://whoogle.${config.networking.domain}";
        WHOOGLE_CONFIG_GET_ONLY = "1";
        WHOOGLE_CONFIG_COUNTRY = "AU";
        WHOOGLE_CONFIG_VIEW_IMAGE = "1";
        WHOOGLE_CONFIG_DISABLE = "1";
        # catppuchin. There are more here: https://github.com/benbusby/whoogle-search/wiki/User-Contributed-CSS-Themes
        WHOOGLE_CONFIG_STYLE = ":root{--whoogle-logo:#4c4f69;--whoogle-page-bg:#eff1f5;--whoogle-element-bg:#bcc0cc;--whoogle-text:#4c4f69;--whoogle-contrast-text:#5c5f77;--whoogle-secondary-text:#6c6f85;--whoogle-result-bg:#ccd0da;--whoogle-result-title:#7287fd;--whoogle-result-url:#dc8a78;--whoogle-result-visited:#e64553;--whoogle-dark-logo:#cdd6f4;--whoogle-dark-page-bg:#1e1e2e;--whoogle-dark-element-bg:#45475a;--whoogle-dark-text:#cdd6f4;--whoogle-dark-contrast-text:#bac2de;--whoogle-dark-secondary-text:#a6adc8;--whoogle-dark-result-bg:#313244;--whoogle-dark-result-title:#b4befe;--whoogle-dark-result-url:#f5e0dc;--whoogle-dark-result-visited:#eba0ac;}#whoogle-w{fill:#89b4fa;}#whoogle-h{fill:#f38ba8;}#whoogle-o-1{fill:#f9e2af;}#whoogle-o-2{fill:#89b4fa;}#whoogle-g{fill:#a6e3a1;}#whoogle-l{fill:#f38ba8;}#whoogle-e{fill:#f9e2af;}";
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