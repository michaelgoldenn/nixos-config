{
  config,
  pkgs,
  ...
}: let
  camIface = "enp3s0"; # cable to the camera
  uplink = "wlan0"; # laptop's Internet NIC
  camSubnet = "10.0.50.0/24"; # the subnet we picked earlier
in {
  # --- NIC gets 10.0.50.1/24 -----------------------------------------------
  networking.interfaces.${camIface}.ipv4.addresses = [
    {
      address = "10.0.50.1";
      prefixLength = 24;
    }
  ];

  # --- Dnsmasq DHCP server --------------------------------------------------
  services.dnsmasq = {
    enable = true;

    /*
    The new interface: every dnsmasq.conf directive is a key.
    If the key contains a hyphen, quote it.
    Single‑value directives   →  string
    Repeated directives       →  list of strings
    Flag (boolean) directives →  true / false
    */
    settings = {
      "interface" = camIface;
      "bind-interfaces" = true;

      "dhcp-range" = "10.0.50.10,10.0.50.100,12h";

      "dhcp-option" = [
        "3,10.0.50.1" # default gateway
        "6,10.0.50.1" # DNS server
      ];

      "no-hosts" = true;
    };
  };

  # --- Laptop NATs the camera subnet ---------------------------------------
  networking.nat = {
    enable = true;
    internalInterfaces = [camIface];
    externalInterface = uplink;
  };

  # --- Optional nftables block‑everything fence ----------------------------
  networking.nftables = {
    enable = true;
    checkRuleset = false;
    tables.filter = {
      family = "ip"; # or "inet" if you want one table for both v4 + v6
      content = ''
        chain forward_cam_out {
          type filter hook forward priority 0;
          iif "${camIface}" ip daddr != ${camSubnet} drop \
            comment "Block camera → Internet when you’re ready"
        }
      '';
    };
  };
}
