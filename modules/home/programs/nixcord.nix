{
  flake,
  pkgs,
  lib,
  ...
}: let
  inherit (flake) config inputs;
  inherit (inputs) self;
  #app = "discord";
  #cfg = config.opt.${app};
in
  # {}
  {
    #options.opt.${app} = {
    #  enable = lib.mkEnableOption "${app}";
    #};
    #config = lib.mkIf cfg.enable {
      imports = [inputs.nixcord.homeManagerModules.nixcord];
      programs.nixcord = {
        enable = true; # also installs discord
        quickCss = "";
        config = {
          useQuickCss = true;
          themeLinks = [
            "https://raw.githubusercontent.com/link/to/some/theme.css"
          ];
          # Vencord options: https://github.com/KaylorBen/nixcord/blob/main/docs/vencord.md
          frameless = true;

          # Plugin Options: https://github.com/KaylorBen/nixcord/blob/main/docs/plugins.md
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
            clearURLs = {
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
            emoteCloner.enable = true;
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
            onePingPerDM = {
              enable = true;
            };
            openInApp = {
              enable = true;
            };
            replyTimestamp.enable = true;
            revealAllSpoilers.enable = true;
            reviewDB = {
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
            USRBG = {
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
  }
