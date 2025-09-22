{
  flake,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (flake) inputs; # this line might look weird. I'm using nixos-unified's autowiring
  inherit (pkgs.nur.repos.rycee) firefox-addons;
  inherit (inputs.rycee-nurpkgs.lib."x86_64-linux") buildFirefoxXpiAddon;
  colors = config.lib.stylix.colors; # import stylix
  c = color: if (builtins.substring 0 1 color) == "#" then color else "#${color}";

  # extensions that all profiles should share
  # try searching here: https://github.com/nix-community/nur-combined/blob/master/repos/rycee/pkgs/firefox-addons/addons.json
  # or run        nix flake show "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"
  # if not there, just search github: https://github.com/search?q=language%3ANix+firefox-addons+&type=code
  global_extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
    bitwarden
    ublock-origin
  ];
  nice_extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
    sponsorblock
    istilldontcareaboutcookies
    unpaywall
    clearurls

    # --- The custom zone ---
    # To get the addon id try downloading the extension first then go to `about:debugging#/runtime/this-firefox`
    # would be nice if there were a better way but I don't know one

    (buildFirefoxXpiAddon {
      # untrap for youtube - not open source :( but the best in it's class
      pname = "untrap-for-youtube";
      version = "8.3.1";
      addonId = "{2662ff67-b302-4363-95f3-b050218bd72c}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4403100/untrap_for_youtube-8.3.1.xpi";
      sha256 = "sha256-nasAQmU3R/uBzs8jwg6Lb0LU0RqYGBrJwxbnboDGVXU=";
      meta = { };
    })
    (buildFirefoxXpiAddon {
      # I hate how linkedin is just another social media
      pname = "linkedin-feed-blocker";
      version = "0.0.3";
      addonId = "{78400a4a-b6fe-4f7d-a831-734229802784}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3795847/linkedin_feed_blocker-0.0.3.xpi";
      sha256 = "sha256-iCZ48z4odTV4/nBlAK6dh8qX5CGVRYaqsTU1z3VKRgw=";
      meta = { };
    })
  ];
  # settings that all profiles should share (about:config for the settings)
  global_settings = {
    # general
    "browser.engagement.ctrlTab.has-used" = true;
    "browser.ctrlTab.sortByRecentlyUsed" = true;
    "browser.startup.page" = 3; # Open previous tabs on startup
    "extensions.autoDisableScopes" = 0; # makes extensions automatically enabled

    # extra bits I won't want
    "extensions.pocket.enabled" = false;
    "extensions.screenshots.disabled" = true;
    "browser.formfill.enable" = false;
    "browser.topsites.contile.enabled" = false;
    "identity.fxaccounts.enabled" = false; # disable firefox accounts (no need for sync when I have nix ;)
    "extensions.formautofill.creditCards.enabled" = false; # disable credit card prompts
    "signon.rememberSignons" = false; # Don't ask about passwords

    # right now just disable all suggestions in the search bar, later go through and see what I like
    "browser.urlbar.showSearchSuggestionsFirst" = false;
    "browser.urlbar.suggest.enabled" = false;
    "browser.urlbar.suggest.bookmark" = false;
    "browser.urlbar.suggest.engines" = false;
    "browser.urlbar.suggest.history" = false;
    "browser.urlbar.suggest.openpage" = false;
    "browser.urlbar.suggest.recentsearches" = false;
    "browser.urlbar.suggest.searches" = false;
    "browser.urlbar.suggest.topsites" = false;
    "browser.urlbar.suggest.calculator" = true; # I do want the calculator though
    "browser.search.suggest.enabled" = true;
    "browser.search.suggest.enabled.private" = false;

    #disable first run stuff (suggestions, welcome page, etc.)
    "app.normandy.first_run" = false;
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "trailhead.firstrun.didSeeAboutWelcome" = false;
    "browser.aboutConfig.showWarning" = false;
    "media.videocontrols.picture-in-picture.video-toggle.has-used" = true; # auto-compress the PIP toggle on videos

    # clean up new tab page
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
  textfox_sidebery_config = builtins.fromJSON (builtins.readFile ./textfox-sidebery-settings.json);
  shyfox_sidebery_config = builtins.fromJSON (builtins.readFile ./shyfox-sidebery-settings.json);
in
{
  programs.firefox = {
    enable = true;
    profiles = {
      textfox = {
        id = 0;
        name = "textfox";
        isDefault = true;
        containersForce = true;
        search = {
          # should eventually make this an option instead of hardcoded
          default = "ddg";

          force = true;
          engines = {
            # hide the other engines
            #"Google".meteData.hidden = true;
            "amazondotcom-us".metaData.hidden = true;
            "bing".metaData.hidden = true;
            "ebay".metaData.hidden = true;

            "ddg" = {
              urls = [
                {
                  template = "https://duckduckgo.com";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
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
              definedAliases = [ "@gn" ];
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
              definedAliases = [ "@hm" ];
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
              definedAliases = [ "@n" ];
            };
          };
        };
        extensions = {
          packages = global_extensions ++ nice_extensions;
          force = true; # need to do this to set extension settings
          settings = {
            # sidebery
            "{3c078156-979c-498b-8990-85f7987dd929}".settings = textfox_sidebery_config;
          };
        };
        settings = global_settings;
      };
      shyfox = {
        id = 1;
        name = "shyfox";
        isDefault = false;
        containersForce = true;
        search = {
          force = true;
        };
        extensions = {
          packages =
            global_extensions
            ++ nice_extensions
            ++ [
              # For now, sidebery can't be configured through central policies
              # so you'll need to import this file into sidebery settings https://github.com/Naezr/ShyFox/blob/main/sidebery-settings.json
              inputs.firefox-addons.packages."x86_64-linux".sidebery
              inputs.firefox-addons.packages."x86_64-linux".userchrome-toggle-extended
            ];
          force = true; # need to do this to set extension settings
          settings = {
            # sidebery
            "{3c078156-979c-498b-8990-85f7987dd929}".settings = shyfox_sidebery_config;
          };
        };
        settings = global_settings // {
          # shyfox specific extensions
          "sidebar.revamp" = false;
          "layout.css.has-selector.enabled" = true;
          "browser.urlbar.suggest.calculator" = true;
          "browser.urlbar.unitConversion.enabled" = true;
          "browser.urlbar.trimHttps" = true;
          "browser.urlbar.trimURLs" = true;
          "widget.gtk.rounded-bottom-corners.enabled" = true;
          "widget.gtk.ignore-bogus-leave-notify" = "1";
        };
      }
      // (
        let
          theme = pkgs.callPackage ./shyfox-import.nix { };
        in
        {
          userChrome = ''
            @import "${theme}/lib/shyfox/userChrome.css";

            /* Minor tweaks */
            :root, #screenshots-component * {
              --sdbr-wdt: 375px;
            }
          '';
          userContent = ''
            @import "${theme}/lib/shyfox/userContent.css";
          '';
        }
      );
      normal = {
        id = 2;
        name = "normal";
        isDefault = false;
        containersForce = true;
        search = {
          force = true;
        };
        extensions.packages = global_extensions;
        settings = global_settings;
      };
    };
    # policy list: https://mozilla.github.io/policy-templates/
    # or check out about:policies#documentation
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
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
      /*
        #extension specific settings
           ExtensionSettings = {
             #bypass paywalls clean: https://gitflic.ru/project/magnolia1234/bpc_uploads
             "magnolia1234@bypass_paywalls_clean" = {
               install_url = "file://${bypass-paywalls-clean}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/magnolia1234@bypass_paywalls_clean.xpi";
               installation_mode = "force_installed";
             };
           };
      */
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
      newtabLogo = ''
            _____           ____
           / __(_)_______  / __/___  _  __
          / /_/ / ___/ _ \/ /_/ __ \| |/_/
         / __/ / /  /  __/ __/ /_/ />  <
        /_/ /_/_/   \___/_/  \____/_/|_|
      '';
    };
  };
}
