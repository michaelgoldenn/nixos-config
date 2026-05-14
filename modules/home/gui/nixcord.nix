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

        # Plugin Options: https://github.com/FlameFlag/nixcord/blob/main/modules/plugins/shared.json
        plugins = {
          accountPanelServerProfile.enable = true;
          alwaysAnimate.enable = true;
          alwaysExpandRoles.enable = true;
          alwaysTrust = {
            enable = true;
            domain = true;
            file = true;
          };
          betterGifAltText.enable = true;
          betterRoleContext.enable = true;
          betterRoleDot.enable = true;
          betterSessions.enable = true;
          betterSettings.enable = true;
          betterUploadButton.enable = true;
          biggerStreamPreview.enable = true;
          callTimer.enable = true;
          characterCounter.enable = true;
          ClearURLs.enable = true;
          colorSighted.enable = true;
          copyEmojiMarkdown.enable = true;
          copyFileContents.enable = true;
          copyStickerLinks.enable = true;
          CopyUserURLs.enable = true;
          crashHandler.enable = true;
          customIdle.enable = true;
          dearrow.enable = true;
          disableCallIdle.enable = false;
          disableDeepLinks.enable = true;
          dontRoundMyTimestamps.enable = true;
          expressionCloner.enable = true;
          fakeNitro.enable = true;
          favoriteGifSearch.enable = true;
          fixCodeblockGap.enable = true;
          fixImagesQuality.enable = true;
          fixSpotifyEmbeds.enable = true;
          fixYoutubeEmbeds.enable = true;
          forceOwnerCrown.enable = true;
          friendInvites.enable = true;
          friendsSince.enable = true;
          fullSearchContext.enable = true;
          fullUserInChatbox.enable = true;
          gameActivityToggle.enable = true;
          gifPaste.enable = true;
          hideMedia.enable = true;
          iLoveSpam.enable = true;
          imageFilename.enable = true;
          imageLink.enable = true;
          imageZoom.enable = true;
          implicitRelationships.enable = true;
          keepCurrentChannel.enable = true;
          memberCount.enable = true;
          mentionAvatars.enable = true;
          messageLatency.enable = true;
          messageLinkEmbeds.enable = true;
          messageLogger.enable = true;
          MutualGroupDMs.enable = true;
          noDevtoolsWarning.enable = true;
          noF1.enable = true;
          noMaskedUrlPaste.enable = true;
          noMosaic.enable = true;
          noOnboardingDelay.enable = true;
          noPendingCount.enable = true;
          noReplyMention.enable = true;
          noServerEmojis.enable = true;
          noSystemBadge.enable = true;
          noTypingAnimation.enable = true;
          noUnblockToJump.enable = true;
          # apparently it's only available in like equicord or something like that? might want to look into it
          # normalizeMessageLinks.enable = true;
          OnePingPerDM.enable = true;
          openInApp.enable = true;
          pauseInvitesForever.enable = true;
          permissionsViewer.enable = true;
          pictureInPicture.enable = true;
          PinDMs.enable = true;
          plainFolderIcon.enable = true;
          quickMention.enable = true;
          quickReply.enable = true;
          readAllNotificationsButton.enable = true;
          relationshipNotifier.enable = true;
          replyTimestamp.enable = true;
          revealAllSpoilers.enable = true;
          reverseImageSearch.enable = true;
          ReviewDB.enable = true;
          roleColorEverywhere.enable = true;
          sendTimestamps.enable = true;
          serverListIndicators.enable = true;
          showAllMessageButtons.enable = true;
          showConnections.enable = true;
          showTimeoutDuration.enable = true;
          silentMessageToggle.enable = true;
          silentTyping.enable = true;
          spotifyCrack.enable = true;
          spotifyShareCommands.enable = true;
          stickerPaste.enable = true;
          streamerModeOnStream.enable = true;
          themeAttributes.enable = true;
          translate.enable = true;
          unindent.enable = true;
          unlockedAvatarZoom.enable = true;
          unsuppressEmbeds.enable = true;
          userMessagesPronouns.enable = true;
          userVoiceShow.enable = true;
          USRBG.enable = true;
          validReply.enable = true;
          validUser.enable = true;
          viewIcons.enable = true;
          viewRaw.enable = true;
          voiceChatDoubleClick.enable = true;
          voiceDownload.enable = true;
          voiceMessages.enable = true;
          volumeBooster.enable = true;
          webScreenShareFixes.enable = true;
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
