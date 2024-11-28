{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;

  # extensions that all profiles should share
  global_extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
    bitwarden
    ublock-origin
    sponsorblock
  ];
  # settings that all profiles should share (about:config for the settings)
  global_settings = {
    # general
    "extensions.pocket.enabled" = false;
    "extensions.screenshots.disabled" = true;
    "browser.topsites.contile.enabled" = false;
    "browser.formfill.enable" = false;
    "browser.engagement.ctrlTab.has-used" = true;
    "browser.ctrlTab.sortByRecentlyUsed" = true;
    "browser.startup.page" = 3; # Open previous windows and tabs
    "identity.fxaccounts.enabled" = false; #disable firefox accounts
    "extensions.formautofill.creditCards.enabled" = false; # disable credit cards

    # right now just disable all suggestions in the search bar, maybe later add some stuff in sparingly?
    "browser.urlbar.showSearchSuggestionsFirst" = false;
    "browser.urlbar.suggest.bookmark" = false;
    "browser.urlbar.suggest.engines" = false;
    "browser.urlbar.suggest.history" = false;
    "browser.urlbar.suggest.openpage" = false;
    "browser.urlbar.suggest,recentsearches" = false;
    "browser.urlbar.suggest.searches" = false;
    "browser.urlbar.suggest.topsites" = false;
    "browser.search.suggest.enabled" = false;
    "browser.search.suggest.enabled.private" = false;

    #disable first run stuff (suggestions, welcome page, etc.)
    "app.normandy.first_run" = false;
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "trailhead.firstrun.didSeeAboutWelcome" = false;
    "browser.aboutConfig.showWarning" = false;


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
    "media.videocontrols.picture-in-picture.video-toggle.has-used" = true; # auto-compress the PIP toggle
  };
in
{
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
/*     policies = {
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
    }; */
  };
  imports = [ inputs.textfox.homeManagerModules.default ];
  textfox = {
    enable = true;
    profile = "textfox";
  };
}