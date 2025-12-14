{
  config,
  lib,
  flake,
  ...
}:
{
  options = {
    webserver.enable = lib.mkEnableOption "webserver";
  };

  config = lib.mkIf config.webserver.enable {
    # Setup nginx to serve your static files
    services.nginx = {
      enable = true;
      user = "server";
      virtualHosts."localhost" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = 8080;
          }
        ];
        root = "/var/www/michael-golden-webserver/dist";
        locations."/" = {
          tryFiles = "$uri $uri/ /index.html"; # SPA fallback
        };
      };
    };

    services.cloudflared = {
      enable = true;
      tunnels = {
        "michael-golden" = {
          credentialsFile = "/home/server/.cloudflared/10074318-a7b7-4e9c-9f1c-ffee1696525a.json";
          default = "http_status:404";

          ingress = {
            "michael-golden.org" = "http://localhost:8080";
            "www.michael-golden.org" = "http://localhost:8080";
          };
        };
      };
    };
  };
}
