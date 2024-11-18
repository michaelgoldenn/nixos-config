{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;

  global_extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
    bitwarden
    ublock-origin
    sponsorblock
  ];

  # goto about:config to see all settings and names
  global_settings = {
    "extensions.pocket.enabled" = false;
    "extensions.screenshots.disabled" = true;
    "browser.topsites.contile.enabled" = false;
    "browser.formfill.enable" = false;
    "browser.search.suggest.enabled" = false;
    "browser.search.suggest.enabled.private" = false;

    # right now just disable everything in the urlbar, maybe later add some stuff in sparingly?
    "browser.urlbar.showSearchSuggestionsFirst" = false;
    "browser.urlbar.suggest.bookmark" = false;
    "browser.urlbar.suggest.engines" = false;
    "browser.urlbar.suggest.history" = false;
    "browser.urlbar.suggest.openpage" = false;
    "browser.urlbar.suggest,recentsearches" = false;
    "browser.urlbar.suggest.searches" = false;
    "browser.urlbar.suggest.topsites" = false;

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
  imports = [ inputs.textfox.homeManagerModules.default ];
  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = ["firefox.desktop"];
    };
  };
  programs.firefox = {
    enable = true;
    profiles = {
      textfox = {
        id = 0;
        name = "textfox";
        isDefault = true;
        extensions = global_extensions;
        settings = global_settings;
      };
      normal = {
        id = 1;
        name = "normal";
        isDefault = false;
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
    };
  };
  textfox = {
    enable = true;
    profile = "textfox";
  };
}