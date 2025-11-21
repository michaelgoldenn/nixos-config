{
  flake,
  config,
  lib,
  ...
}:
{
  imports = [ flake.inputs.nixcord.homeModules.nixcord ];
  options.nixcord.enable = lib.mkEnableOption "nixcord";
  config = lib.mkIf config.nixcord.enable {
    programs.nixcord = {
      enable = true; # also installs discord
      quickCss = "";
      config = {
        useQuickCss = true;
        themeLinks = [
          "https://raw.githubusercontent.com/link/to/some/theme.css"
        ];
        # Vencord options: https://github.com/KaylorBen/nixcord
        # frameless = true;

        # Plugin Options: https://github.com/KaylorBen/nixcord/blob/main/modules/plugins.nix
        plugins = {
          alwaysExpandRoles.enable = true;
          alwaysTrust = {
            enable = true;
            domain = true;
            file = true;
          };
          betterSessions = {
            enable = true;
          };
          betterSettings = {
            enable = true;
          };
          callTimer = {
            enable = true; # Disabled as it made me crash on every call join
          };
          clearUrLs = {
            enable = true;
          };
          copyEmojiMarkdown = {
            enable = true;
          };
          copyFileContents = {
            enable = true;
          };
          crashHandler = {
            enable = true;
          };
          customIdle = {
            enable = true;
          };
          disableCallIdle.enable = false;
          #emoteCloner.enable = true;
          fakeNitro = {
            enable = true;
          };
          fixSpotifyEmbeds = {
            enable = true;
          };
          fixYoutubeEmbeds = {
            enable = true;
          };
          fullSearchContext.enable = true;
          gameActivityToggle = {
            enable = true;
          };
          imageZoom = {
            enable = true;
          };
          keepCurrentChannel = {
            enable = true;
          };
          mentionAvatars = {
            enable = true;
          };
          messageLogger = {
            enable = true;
          };
          noF1 = {
            enable = true;
          };
          noOnboardingDelay.enable = true;
          noReplyMention = {
            enable = true;
          };
          normalizeMessageLinks.enable = true;
          noTypingAnimation = {
            enable = true;
          };
          noUnblockToJump.enable = true;
          onePingPerDm = {
            enable = true;
          };
          openInApp = {
            enable = true;
          };
          replyTimestamp.enable = true;
          revealAllSpoilers.enable = true;
          reviewDb = {
            enable = true;
          };
          sendTimestamps = {
            enable = true;
          };
          silentTyping = {
            enable = true;
          };
          spotifyCrack = {
            enable = true;
          };
          themeAttributes = {
            enable = true;
          };
          unindent.enable = true;
          userMessagesPronouns = {
            enable = true;
          };
          usrbg = {
            enable = true;
          };
          validReply.enable = true;
          validUser.enable = true;
          voiceChatDoubleClick.enable = true;
          volumeBooster = {
            enable = true;
          };
          youtubeAdblock.enable = true;
        };
      };
      extraConfig = {
        # Some extra JSON config here
        # ...
      };
      #};
    };
  };
}
