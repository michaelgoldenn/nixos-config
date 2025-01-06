{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
  inherit (pkgs.nur.repos.rycee) firefox-addons;

  # extensions that all profiles should share
  # try searching here: https://github.com/nix-community/nur-combined/blob/master/repos/rycee/pkgs/firefox-addons/addons.json
  # or run        nix flake show "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"
  # if not there, just search github: https://github.com/search?q=language%3ANix+firefox-addons+&type=code
  #inherit (nur.repos.rycee) firefox-addons;
  #bypass-paywalls-clean = firefox-addons.bypass-paywalls-clean.override rec {
  #  version = "3.9.4.0";
  #  url = "https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass_paywalls_clean-${version}.xpi";
  #  sha256 = "sha256-LpeM08XTGuiNEsMnln9tW/1svjOi1OhssmMnf+Xae80=";
  #};
  
  global_extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
    bitwarden
    ublock-origin
    sponsorblock
    istilldontcareaboutcookies
    unpaywall
    clearurls
    #bypass-paywalls-clean
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
      #extension specific settings
      ExtensionSettings = {
        #bypass paywalls clean: https://gitflic.ru/project/magnolia1234/bpc_uploads
        #"${bypass-paywalls-clean.addonId}" = {
        #  install_url = "file://${bypass-paywalls-clean}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${bypass-paywalls-clean.addonId}.xpi";
        #  installation_mode = "force_installed";
        #};
      };
    };
  };
  imports = [ inputs.textfox.homeManagerModules.default ];
  textfox = {
    enable = true;
    profile = "textfox";
  };
}
