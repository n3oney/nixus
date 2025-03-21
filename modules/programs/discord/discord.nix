{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.programs.discord;
  inherit (lib) mkEnableOption mkIf;
in {
  options.programs.discord = {
    enable = mkEnableOption "discord";
    package = lib.mkOption {
      default = pkgs.vesktop;
    };
    finalPackage = lib.mkOption {
      readOnly = true;
      default = cfg.package.overrideAttrs (old: {
        # patches = (old.patches or []) ++ [./readonlyFix.patch];
        postFixup =
          (old.postFixup or "")
          + ''
            wrapProgram $out/bin/${cfg.package.meta.mainProgram or (lib.getName cfg.package)} \
              --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
          '';
      });
    };
  };

  config.impermanence.userDirs = lib.mkIf cfg.enable [".config/vesktop"];

  config.hm = mkIf cfg.enable {
    home.packages = [
      cfg.finalPackage
    ];

    xdg.configFile."vesktop/settings.json".text = builtins.toJSON {
      discordBranch = "canary";
      firstLaunch = false;
      arRPC = "on";
      splashColor = "rgb(219, 222, 225)";
      splashBackground = "rgb(49, 51, 56)";
      enableMenu = false;
      staticTitle = false;
      transparencyOption = "I love NixOS";
    };

    xdg.configFile."vesktop/settings/settings.json".text = builtins.toJSON {
      notifyAboutUpdates = false;
      autoUpdate = false;
      autoUpdateNotification = false;
      useQuickCss = true;
      themeLinks = [];
      enabledThemes = ["Catppuccin.theme.css"];
      enableReactDevtools = true;
      frameless = false;
      transparent = true;
      winCtrlQ = false;
      macosTranslucency = false;
      disableMinSize = false;
      winNativeTitleBar = false;
      plugins = {
        AlwaysAnimate.enabled = false;
        AlwaysTrust.enabled = false;
        AnonymiseFileNames.enabled = false;
        BadgeAPI.enabled = true;
        CommandsAPI.enabled = true;
        ContextMenuAPI.enabled = true;
        MemberListDecoratorsAPI.enabled = false;
        MessageAccessoriesAPI.enabled = false;
        MessageDecorationsAPI.enabled = false;
        MessageEventsAPI.enabled = false;
        MessagePopoverAPI.enabled = false;
        NoticesAPI.enabled = true;
        ServerListAPI.enabled = false;
        ShowTimeouts.enabled = true;
        SettingsStoreAPI.enabled = false;
        "WebRichPresence (arRPC)".enabled = true;
        BANger.enabled = false;
        BetterFolders.enabled = false;
        BetterGifAltText.enabled = true;
        BetterNotesBox.enabled = false;
        BetterRoleDot.enabled = false;
        BetterUploadButton.enabled = true;
        BlurNSFW.enabled = false;
        CallTimer.enabled = true;
        ClearURLs.enabled = true;
        ColorSighted.enabled = false;
        ConsoleShortcuts.enabled = false;
        CrashHandler.enabled = true;
        CustomRPC.enabled = false;
        DisableDMCallIdle.enabled = false;
        EmoteCloner.enabled = false;
        Experiments.enabled = true;
        F8Break.enabled = false;
        FakeNitro.enabled = false;
        FakeProfileThemes.enabled = true;
        FavoriteEmojiFirst.enabled = true;
        Fart2.enabled = false;
        FixInbox.enabled = false;
        ForceOwnerCrown.enabled = true;
        FriendInvites.enabled = false;
        FxTwitter.enabled = false;
        GameActivityToggle.enabled = true;
        GifPaste.enabled = false;
        HideAttachments.enabled = false;
        iLoveSpam.enabled = false;
        IgnoreActivities.enabled = false;
        ImageZoom.enabled = true;
        InvisibleChat = {
          enabled = true;
          savedPasswords = "password";
        };
        KeepCurrentChannel.enabled = true;
        LastFMRichPresence.enabled = false;
        LoadingQuotes.enabled = false;
        MemberCount.enabled = true;
        MessageClickActions.enabled = false;
        MessageLinkEmbeds.enabled = true;
        MessageLogger.enabled = true;
        MessageTags.enabled = false;
        MoreCommands.enabled = true;
        MoreKaomoji.enabled = false;
        MoreUserTags.enabled = false;
        Moyai.enabled = false;
        MuteNewGuild.enabled = false;
        NoBlockedMessages.enabled = true;
        NoCanaryMessageLinks.enabled = false;
        NoDevtoolsWarning.enabled = true;
        NormalizeMessageLinks.enabled = true;
        NoF1.enabled = true;
        NoMosaic.enabled = true;
        NoReplyMention = {
          # don't ping vaxry pls
          userList = "372809091208445953";
          enabled = true;
          shouldPingListed = false;
        };
        NoScreensharePreview.enabled = false;
        NoTrack.enabled = true;
        NoTypingAnimation.enabled = true;
        NoUnblockToJump.enabled = true;
        NSFWGateBypass.enabled = false;
        oneko.enabled = false;
        petpet.enabled = false;
        PinDMs.enabled = false;
        PlainFolderIcon.enabled = false;
        PlatformIndicators.enabled = true;
        PronounDB.enabled = false;
        QuickMention.enabled = false;
        QuickReply.enabled = true;
        ReadAllNotificationsButton.enabled = true;
        RelationshipNotifier.enabled = true;
        RevealAllSpoilers.enabled = false;
        ReverseImageSearch.enabled = false;
        ReviewDB.enabled = true;
        RoleColorEverywhere.enabled = true;
        SearchReply.enabled = false;
        SendTimestamps.enabled = true;
        ServerListIndicators.enabled = false;
        Settings = {
          enabled = true;
          settingsLocation = "aboveActivity";
        };
        ShikiCodeblocks.enabled = false;
        ShowHiddenChannels.enabled = false;
        ShowMeYourName.enabled = false;
        SilentMessageToggle.enabled = false;
        SilentTyping.enabled = true;
        SortFriendRequests.enabled = false;
        SpotifyControls.enabled = false;
        SpotifyCrack.enabled = false;
        SpotifyShareCommands.enabled = false;
        StartupTimings.enabled = false;
        SupportHelper.enabled = true;
        TimeBarAllActivities.enabled = false;
        TypingIndicator.enabled = true;
        TypingTweaks.enabled = true;
        Unindent.enabled = true;
        ReactErrorDecoder.enabled = false;
        UrbanDictionary.enabled = false;
        UserVoiceShow.enabled = false;
        USRBG.enabled = false;
        UwUifier.enabled = true;
        VoiceChatDoubleClick.enabled = true;
        VcNarrator.enabled = false;
        ViewIcons.enabled = false;
        ViewRaw.enabled = false;
        WebContextMenus = {
          enabled = true;
          addBack = false;
        };
        GreetStickerPicker.enabled = false;
        WhoReacted.enabled = true;
        Wikisearch.enabled = false;
        WebKeybinds.enabled = true;
      };
      notifications = {
        timeout = 5000;
        position = "bottom-right";
        useNative = "not-focused";
        logLimit = 50;
      };
      cloud = {
        authenticated = false;
        url = "https://api.vencord.dev/";
        settingsSync = false;
        settingsSyncVersion = 1682768329526;
      };
    };
  };
}
