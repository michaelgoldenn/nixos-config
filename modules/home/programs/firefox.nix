{ flake, lib, config, inheritedConfig, pkgs, ... }:
let
  inherit (flake) inputs; # this line might look weird. I'm using nixos-unified's autowiring
  inherit (pkgs.nur.repos.rycee) firefox-addons;

  # need to do this one in a special way because it got banned from everywhere for copyright violation lol
  # if you ever get an error about this, that means you need to update the version, go here:
  # https://gitflic.ru/project/magnolia1234/bpc_uploads
  # and get the newest version, the update the sha256
  bypass-paywalls-clean = firefox-addons.bypass-paywalls-clean.override rec {
    version = "latest";
    url = "https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass_paywalls_clean-${version}.xpi";
    sha256 = "sha256-mXDE02yM78nv3UBkAP9JNFsm+Gz2bFDhENZjiaLRZ4w=";
  };

  cfg = inheritedConfig;
  colors = config.lib.stylix.colors; # import stylix
  c = color: if (builtins.substring 0 1 color) == "#" then color else "#${color}";

  # extensions that all profiles should share
  # try searching here: https://github.com/nix-community/nur-combined/blob/master/repos/rycee/pkgs/firefox-addons/addons.json
  # or run        nix flake show "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"
  # if not there, just search github: https://github.com/search?q=language%3ANix+firefox-addons+&type=code  
  global_extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
    bitwarden
    ublock-origin
    sponsorblock
    istilldontcareaboutcookies
    unpaywall
    clearurls
    bypass-paywalls-clean
    #untrap-for-youtube
  ];
  # settings that all profiles should share (about:config for the settings)
  global_settings = {
    # general
    "browser.engagement.ctrlTab.has-used" = true;
    "browser.ctrlTab.sortByRecentlyUsed" = true;
    "browser.startup.page" = 3; # Open previous tabs on startup
    
    # extra bits I won't want
    "extensions.pocket.enabled" = false;
    "extensions.screenshots.disabled" = true;
    "browser.formfill.enable" = false;
    "browser.topsites.contile.enabled" = false;
    "identity.fxaccounts.enabled" = false; #disable firefox accounts (no need for sync when I have nix ;)
    "extensions.formautofill.creditCards.enabled" = false; # disable credit card prompts
    "signon.rememberSignons" = false; # Don't ask about passwords

    # right now just disable all suggestions in the search bar, later go through and see what I like
    "browser.urlbar.showSearchSuggestionsFirst" = false;
    "browser.urlbar.suggest.bookmark" = false;
    "browser.urlbar.suggest.engines" = false;
    "browser.urlbar.suggest.history" = false;
    "browser.urlbar.suggest.openpage" = false;
    "browser.urlbar.suggest.recentsearches" = false;
    "browser.urlbar.suggest.searches" = false;
    "browser.urlbar.suggest.topsites" = false;
    "browser.search.suggest.enabled" = true;
    "browser.search.suggest.enabled.private" = false;
    "browser.urlbar.suggest.calculator" = true; # I do want the calculator though

    #disable first run stuff (suggestions, welcome page, etc.)
    "app.normandy.first_run" = false;
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "trailhead.firstrun.didSeeAboutWelcome" = false;
    "browser.aboutConfig.showWarning" = false;
    "media.videocontrols.picture-in-picture.video-toggle.has-used" = true; # auto-compress the PIP toggle

    # change new tab page
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
    "browser.newtabpage.activity-stream.feeds.snippets" = false;
    "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
    "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
    "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
    "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.system.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.feeds.topsites" = false; # Firefox "shortcuts" on new tab page
  };
in
{
/*   systemd.services.update-bypass-paywalls = {
    description = "Update bypass-paywalls-clean hash";
    script = ''
      VERSION="latest"
      URL="https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass_paywalls_clean-''${VERSION}.xpi"
      NEW_HASH=$(nix-prefetch-url "$URL")
      sed -i "s|sha256 = \".*\"|sha256 = \"sha256-$NEW_HASH\"|" /path/to/your/nix/file
    '';
    before = [ "nixos-rebuild.service" ];
    wantedBy = [ "nixos-rebuild.service" ];
  }; */
  programs.firefox = {
    enable = true;
    profiles = {
      textfox = {
        id = 0;
        name = "textfox";
        isDefault = true;
        containersForce = true;
        search = {
          # should eventually change this default to something better
          default = if cfg.services.whoogle.enable then "Whoogle" else "DuckDuckGo";
          
          force = true;


          engines = {
            # hide the other engines
            #"Google".meteData.hidden = true;
            "Amazon.com".metaData.hidden = true;
            "Bing".metaData.hidden = true;
            "eBay".metaData.hidden = true;


            "DuckDuckGo" = {
              urls = [{
                template = "https://duckduckgo.com";
                params = [
                  { name = "q"; value = "{searchTerms}"; }
                ];
              }];
              definedAliases = [ ",d" ];
            };
            "Github Nix" = {
              urls = [
                {
                  template = "https://github.com/search";
                  params = [
                    {
                      name = "q";
                      value = "lang:nix+{searchTerms}";
                    }
                    {
                      name = "type";
                      value = "code";
                    }
                  ];
                }
              ];
              definedAliases = ["@gn"];
            };
            "Home Manager" = {
              urls = [
                {
                  template = "https://home-manager-options.extranix.com/";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}+&release=master";
                    }
                  ];
                }
              ];
              definedAliases = ["@hm"];
            };
            "Nix Search" = {
              urls = [
                {
                  template = "https://mynixos.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              definedAliases = ["@n"];
            };
            config = lib.mkIf cfg.services.whoogle.enable { # rip whoogle, I just finished customizing you when you died :(
              "Whoogle" = let whoogle = "0.0.0.0:5000"; in {
                urls = [{ template = "http://${whoogle}/search?q={searchTerms}"; }];
                iconUpdateURL = "https://${whoogle}/static/img/favicon/apple-icon-144x144.png";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = [ "!wh" ];
                method = "POST";
              };
            };
          };
        };
        extensions = global_extensions;
        settings = global_settings;
      };
      normal = {
        id = 1;
        name = "normal";
        isDefault = false;
        containersForce = true;
        search = {
          force = true;
        };
        extensions = global_extensions;
        settings = global_settings;
      };
    };
    # policy list: https://mozilla.github.io/policy-templates/
    # or check out about:policies#documentation
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value= true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
      #extension specific settings
      ExtensionSettings = {
        #bypass paywalls clean: https://gitflic.ru/project/magnolia1234/bpc_uploads
        "${bypass-paywalls-clean.addonId}" = {
          install_url = "file://${bypass-paywalls-clean}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${bypass-paywalls-clean.addonId}.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };
  imports = [ inputs.textfox.homeManagerModules.default ];
  textfox = {
    enable = true;
    profile = "textfox";
    config = {
      background = {
        color = "${c colors.base00}";
      };
      border = {
        color = "${c colors.base03}";
      };
      font = { 
        #family = "Fira Code";
        #size = "15px";
        accent = "${c colors.base08}";
      };
    };
  };
}
