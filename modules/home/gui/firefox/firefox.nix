{
  flake,
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
  # try searching here: https://github.com/nix-community/nur-combined/blob/main/repos/rycee/pkgs/firefox-addons/addons.json
  # or run        nix flake show "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"
  # if not there, just search github: https://github.com/search?q=language%3ANix+firefox-addons+&type=code
  global_extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
    bitwarden
    ublock-origin
    aw-watcher-web
  ];
  nice_extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
    sponsorblock
    istilldontcareaboutcookies
    unpaywall
    clearurls
    web-clipper-obsidian

    # --- The custom zone ---
    # to get the url right-click the "add to firefox" button and copy the url
    # To get the addon id try downloading the extension first then go to `about:debugging#/runtime/this-firefox`
    # would be nice if there were a better way but I don't know one
    # to get the version just copy it from the

    (buildFirefoxXpiAddon {
      # checks websites against the FMHY list, especially useful for avoiding fake verions of websites
      pname = "fmhy-safeguard";
      version = "1.3.5";
      addonId = "{5d554479-7cc4-487f-bd25-d8fc67a42602}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4684016/fmhy_safeguard-1.3.5.xpi";
      sha256 = "sha256-CD3mBO/xTmuyXZUSN/cgSY11n0a/xImhQD5eU1ZFHcM=";
      meta = { };
    })
    (buildFirefoxXpiAddon {
      # Shows a popup and notifications when the current site may have an article on the Consumer Rights Wiki.
      pname = "consumer-rights-wiki";
      version = "1.0.8";
      addonId = "{f9e227ec-dff7-4c7f-92ad-c3ed5c4370e1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4709432/consumer_rights_wiki-1.0.8.xpi";
      sha256 = "sha256-bVRgITSdheBGhH1clpOQVIaUmTOm+sEjyrJe7ra7ei4=";
      meta = { };
    })
    (buildFirefoxXpiAddon {
      # webserial for firefox, useful for things like flashing esp32 boards
      pname = "webserial-for-firefox";
      version = "0.5.0";
      addonId = "{746d26e0-6afe-462f-a269-f071566c2700}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4666470/webserial_for_firefox-0.5.0.xpi";
      sha256 = "sha256-AKq2RqPw6LtIuajhpyU7NGVLkPS1ToVTqqNPVQ5iJP4=";
      meta = { };
    })
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
    (buildFirefoxXpiAddon {
      # autofills job-related stuff
      pname = "simplify-jobs";
      version = "2.2.14";
      addonId = "{c3dee1e3-4298-4bb6-810a-3ff1ded5c5f6}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4644850/simplify_jobs-2.2.14.xpi";
      sha256 = "sha256-Om01/FHiLA18o470Ly0F830m36LiVO9yjYx7taUXDfs=";
      meta = { };
    })
    (buildFirefoxXpiAddon {
      # ToS;DR - a tl;dr but for terms of service.
      pname = "Terms of Service; Didn’t Read";
      version = "5.1.1";
      addonId = "{5d0b323e-2e88-4064-8242-7b89e4c372b7}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4464742/terms_of_service_didnt_read-5.1.1.xpi";
      sha256 = "sha256-resAl04BF3VIv8Blvh0pwMfimS1mhM7SxVXKiNxF8kM=";
      meta = { };
    })
    (buildFirefoxXpiAddon {
      pname = "bypass-paywalls-clean";
      version = "3.9.4.0";
      addonId = "magnolia1234@bypass_paywalls_clean";
      url = "https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass_paywalls_clean-4.3.4.7.xpi&inline=false&commit=3fd5f494ea96ad59902766e2dcf39195392452db";
      sha256 = "sha256-Nnl7KJaRQ/TrMmkVpLY7dCPtTR+qLF9SCcLGElQg+u8=";
      meta = { };
    })
  ];
  # settings that all profiles should share (about:config for the settings)
  global_settings = {
    # general
    "browser.engagement.ctrlTab.has-used" = true;
    "browser.ctrlTab.sortByRecentlyUsed" = true;
    "browser.startup.page" = 3; # Open previous tabs on startup
    "extensions.autoDisableScopes" = 0; # makes extensions automatically enabled (doesn't actually work)
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    ## TODO: Set this to only run on computers that don't support hardware AV1 (right now none of them do)
    "media.av1.enabled" = false;

    # extra bits I won't want
    "extensions.pocket.enabled" = false;
    "extensions.screenshots.disabled" = true;
    "browser.formfill.enable" = false;
    "browser.topsites.contile.enabled" = false;
    "identity.fxaccounts.enabled" = false; # disable firefox accounts (no need for sync when I have nix ;)
    "extensions.formautofill.creditCards.enabled" = false; # disable credit card prompts
    "signon.rememberSignons" = false; # Don't ask about passwords
    "datareporting.healthreport.uploadEnabled" = false; # don't want to send interaction data (I'm fine with sending usage pings though)

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
    "browser.urlbar.quicksuggest.enabled" = false; # this shows ads when you type in your search bar lol

    #disable first run stuff (suggestions, welcome page, etc.)
    "app.normandy.first_run" = false;
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "browser.aboutwelcome.enabled" = false;
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
    "browser.newtabpage.activity-stream.feeds.topsites" = false; # Firefox "shortcuts"
  };

  # sidebery configs. If you want to replace the current config with a new one, it is located in:
  # ~/.mozilla/firefox/<profile_name>/browser-extension-data/{3c078156-979c-498b-8990-85f7987dd929}/storage.js
  textfox_sidebery_config = builtins.fromJSON (builtins.readFile ./textfox-sidebery-settings.json);
  shyfox_sidebery_config = builtins.fromJSON (builtins.readFile ./shyfox-sidebery-settings.json);
in
{
  # set firefox to be default for html
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
  programs.firefox = {
    enable = true;
    # configPath = "${config.xdg.configHome}/mozilla/firefox";
    configPath = ".mozilla/firefox";
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
            # hide engines I don't want
            "amazondotcom-us".metaData.hidden = true;
            "bing".metaData.hidden = true;
            "ebay".metaData.hidden = true;
            # custom definitions for search engines
            google.definedAliases = [ "@g" ];
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
              definedAliases = [ "@d" ];
            };
            "Github Search" = {
              urls = [
                {
                  template = "https://github.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                    {
                      name = "type";
                      value = "code";
                    }
                  ];
                }
              ];
              definedAliases = [ "@gh" ];
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
            "Nix Wiki" = {
              urls = [
                {
                  template = "https://wiki.nixos.org/w/";
                  params = [
                    {
                      name = "";
                      value = "index.php?search={searchTerms}";
                    }
                  ];
                }
              ];
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
        extensions = {
          force = true;
          packages = global_extensions;
        };
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
      ExtensionSettings = {
        "magnolia1234@bypass_paywalls_clean" = {
          installation_mode = "force_installed";
          install_url = "https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass_paywalls_clean-3.9.4.0.xpi";
        };
      };
    };
  };
  imports = [ inputs.textfox.homeManagerModules.default ];
  textfox = {
    enable = true;
    profiles = [ "textfox" ];
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
