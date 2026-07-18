{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.chromium;

  defaultProfile = lib.filterAttrs (k: v: v != null) {
    DefaultSearchProviderEnabled = cfg.defaultSearchProviderEnabled;
    DefaultSearchProviderSearchURL = cfg.defaultSearchProviderSearchURL;
    DefaultSearchProviderSuggestURL = cfg.defaultSearchProviderSuggestURL;
    ExtensionInstallForcelist = cfg.extensions;
    HomepageLocation = cfg.homepageLocation;
  };
in

{
  ###### interface

  options = {
    programs.chromium = {
      enable = lib.mkEnableOption "policies for chromium based browsers like Chromium, Google Chrome or Brave";

      defaultSearchProviderEnabled = lib.mkOption {
        default = null;
        description = "Enable the default search provider.";
        example = true;
        type = lib.types.nullOr lib.types.bool;
      };

      defaultSearchProviderSearchURL = lib.mkOption {
        default = null;
        description = "Chromium default search provider url.";
        example = "https://encrypted.google.com/search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}{google:instantExtendedEnabledParameter}ie={inputEncoding}";
        type = lib.types.nullOr lib.types.str;
      };

      defaultSearchProviderSuggestURL = lib.mkOption {
        default = null;
        description = "Chromium default search provider url for suggestions.";
        example = "https://encrypted.google.com/complete/search?output=chrome&q={searchTerms}";
        type = lib.types.nullOr lib.types.str;
      };

      enablePlasmaBrowserIntegration = lib.mkEnableOption "Native Messaging Host for Plasma Browser Integration";

      extensions = lib.mkOption {
        default = null;

        description = ''
          List of chromium extensions to install.
          For list of plugins ids see id in url of extensions on
          [chrome web store](https://chrome.google.com/webstore/category/extensions)
          page. To install a chromium extension not included in the chrome web
          store, append to the extension id a semicolon ";" followed by a URL
          pointing to an Update Manifest XML file. See
          [ExtensionInstallForcelist](https://cloud.google.com/docs/chrome-enterprise/policies/?policy=ExtensionInstallForcelist)
          for additional details.
        '';

        example = lib.literalExpression ''
          [
            "chlffgpmiacpedhhbkiomidkjlcfhogd" # pushbullet
            "mbniclmhobmnbdlbpiphghaielnnpgdp" # lightshot
            "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
            "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
          ]
        '';

        type = with lib.types; nullOr (listOf str);
      };

      extraOpts = lib.mkOption {
        default = { };

        description = ''
          Extra chromium policy options. A list of available policies
          can be found in the Chrome Enterprise documentation:
          <https://cloud.google.com/docs/chrome-enterprise/policies/>
          Make sure the selected policy is supported on Linux and your browser version.
        '';

        example = lib.literalExpression ''
          {
            "BrowserSignin" = 0;
            "SyncDisabled" = true;
            "PasswordManagerEnabled" = false;
            "SpellcheckEnabled" = true;
            "SpellcheckLanguage" = [
              "de"
              "en-US"
            ];
          }
        '';

        type = lib.types.attrs;
      };

      homepageLocation = lib.mkOption {
        default = null;
        description = "Chromium default homepage";
        example = "https://nixos.org";
        type = lib.types.nullOr lib.types.str;
      };

      initialPrefs = lib.mkOption {
        default = { };

        description = ''
          Initial preferences are used to configure the browser for the first run.
          Unlike {option}`programs.chromium.extraOpts`, initialPrefs can be changed by users in the browser settings.
          More information can be found in the Chromium documentation:
          <https://www.chromium.org/administrators/configuring-other-preferences/>
        '';

        example = lib.literalExpression ''
          {
            "first_run_tabs" = [
              "https://nixos.org/"
            ];
          }
        '';

        type = lib.types.attrs;
      };

      plasmaBrowserIntegrationPackage = lib.mkPackageOption pkgs [
        "kdePackages"
        "plasma-browser-integration"
      ] { };
    };
  };

  ###### implementation

  config = {
    environment.etc = lib.mkIf cfg.enable {
      # for brave
      "brave/policies/managed/default.json" = lib.mkIf (defaultProfile != { }) {
        text = builtins.toJSON defaultProfile;
      };

      "brave/policies/managed/extra.json" = lib.mkIf (cfg.extraOpts != { }) {
        text = builtins.toJSON cfg.extraOpts;
      };

      "chromium/initial_preferences" = lib.mkIf (cfg.initialPrefs != { }) {
        text = builtins.toJSON cfg.initialPrefs;
      };

      # for chromium
      "chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json" =
        lib.mkIf cfg.enablePlasmaBrowserIntegration
          {
            source = "${cfg.plasmaBrowserIntegrationPackage}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
          };

      "chromium/policies/managed/default.json" = lib.mkIf (defaultProfile != { }) {
        text = builtins.toJSON defaultProfile;
      };

      "chromium/policies/managed/extra.json" = lib.mkIf (cfg.extraOpts != { }) {
        text = builtins.toJSON cfg.extraOpts;
      };

      # for google-chrome https://www.chromium.org/administrators/linux-quick-start
      "opt/chrome/native-messaging-hosts/org.kde.plasma.browser_integration.json" =
        lib.mkIf cfg.enablePlasmaBrowserIntegration
          {
            source = "${cfg.plasmaBrowserIntegrationPackage}/etc/opt/chrome/native-messaging-hosts/org.kde.plasma.browser_integration.json";
          };

      "opt/chrome/policies/managed/default.json" = lib.mkIf (defaultProfile != { }) {
        text = builtins.toJSON defaultProfile;
      };

      "opt/chrome/policies/managed/extra.json" = lib.mkIf (cfg.extraOpts != { }) {
        text = builtins.toJSON cfg.extraOpts;
      };
    };
  };
}
