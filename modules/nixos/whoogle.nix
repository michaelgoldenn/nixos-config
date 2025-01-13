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
      ports = [ (builtins.toString port) ]; # expose port
      environment = {
        TZ = "${config.time.timeZone}";
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
        WHOOGLE_CONFIG_ALTS = "1";
        WHOOGLE_CONFIG_THEME = "system";
        WHOOGLE_CONFIG_URL = "https://whoogle.${config.networking.domain}";
        WHOOGLE_CONFIG_GET_ONLY = "1";
        WHOOGLE_CONFIG_COUNTRY = "AU";
        WHOOGLE_CONFIG_VIEW_IMAGE = "1";
        WHOOGLE_CONFIG_DISABLE = "1";
      };
    };

    services.nginx.virtualHosts."${app}.${config.networking.domain}" = {
      # Remove or comment out these lines for local testing
      useACMEHost = config.networking.domain;
      forceSSL = true;
      locations."^~ /" = {
        proxyPass = "http://${app}:${builtins.toString port}";
        extraConfig = "resolver 10.88.0.1;";
      };
    };

      # I don't need homepage management
/*     mySystem.services.homepage.home = mkIf cfg.addToHomepage [
      {
        Whoogle = {
          icon = "whooglesearch.png";
          href = "https://${app}.${config.networking.domain}";  # Changed from mySystem.domain
          description = "Google frontend";
          container = "${app}";
        };
      }
    ]; */

    # commented out for now
/*     mySystem.services.gatus.monitors = [{
      name = app;
      group = "services";
      url = "https://${app}.${config.networking.domain}/healthz";  # Changed from mySystem.domain
      interval = "1m";
      conditions = [ "[CONNECTED] == true" "[STATUS] == 200" "[RESPONSE_TIME] < 50" ];
    }]; */


  };
}