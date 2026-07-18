{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.firefox;

  policyFormat = pkgs.formats.json { };

  organisationInfo = ''
    When this option is in use, Firefox will inform you that "your browser
    is managed by your organisation". That message appears because NixOS
    installs what you have declared here such that it cannot be overridden
    through the user interface. It does not mean that someone else has been
    given control of your browser, unless of course they also control your
    NixOS configuration.
  '';
in
{
  imports =
    lib.mapAttrsToList
      (
        name: pkg:
        lib.mkRemovedOptionModule [
          "programs"
          "firefox"
          "nativeMessagingHosts"
          name
        ] "Use `programs.firefox.nativeMessagingHosts.packages = [ pkgs.${pkg} ]` instead"
      )
      {
        browserpass = "browserpass";
        bukubrow = "bukubrow";
        euwebid = "web-eid-app";
        ff2mpv = "ff2mpv";
        fxCast = "fx-cast-bridge";
        gsconnect = "gnomeExtensions.gsconnect";
        jabref = "jabref";
        passff = "passff-host";
        tridactyl = "tridactyl-native";
        ugetIntegrator = "uget-integrator";
      };

  options.programs.firefox = {
    enable = lib.mkEnableOption "the Firefox web browser";

    package = lib.mkOption {
      default = pkgs.firefox;
      defaultText = lib.literalExpression "pkgs.firefox";
      description = "Firefox package to use.";

      relatedPackages = [
        "firefox"
        "firefox-bin"
        "firefox-esr"
      ];

      type = lib.types.package;
    };

    autoConfig = lib.mkOption {
      default = "";

      description = ''
        AutoConfig files can be used to set and lock preferences that are not covered
        by the policies.json for Mac and Linux. This method can be used to automatically
        change user preferences or prevent the end user from modifying specific
        preferences by locking them. More info can be found in <https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig>.
      '';

      type = lib.types.lines;
    };

    autoConfigFiles = lib.mkOption {
      default = [ ];

      description = ''
        AutoConfig files can be used to set and lock preferences that are not covered
        by the policies.json for Mac and Linux. This method can be used to automatically
        change user preferences or prevent the end user from modifying specific
        preferences by locking them. More info can be found in <https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig>.

        Files are concatenated and autoConfig is appended.
      '';

      type = with lib.types; listOf path;
    };

    finalPackage = lib.mkOption {
      description = "Resulting customized Firefox package.";
      readOnly = true;
      type = lib.types.package;
      visible = false;
    };

    languagePacks = lib.mkOption {
      default = [ ];

      description = ''
        The language packs to install.
      '';

      # Available languages can be found in https://releases.mozilla.org/pub/firefox/releases/${cfg.package.version}/linux-x86_64/xpi/
      type = lib.types.listOf (
        lib.types.enum [
          "ach"
          "af"
          "an"
          "ar"
          "ast"
          "az"
          "be"
          "bg"
          "bn"
          "br"
          "bs"
          "ca-valencia"
          "ca"
          "cak"
          "cs"
          "cy"
          "da"
          "de"
          "dsb"
          "el"
          "en-CA"
          "en-GB"
          "en-US"
          "eo"
          "es-AR"
          "es-CL"
          "es-ES"
          "es-MX"
          "et"
          "eu"
          "fa"
          "ff"
          "fi"
          "fr"
          "fur"
          "fy-NL"
          "ga-IE"
          "gd"
          "gl"
          "gn"
          "gu-IN"
          "he"
          "hi-IN"
          "hr"
          "hsb"
          "hu"
          "hy-AM"
          "ia"
          "id"
          "is"
          "it"
          "ja"
          "ka"
          "kab"
          "kk"
          "km"
          "kn"
          "ko"
          "lij"
          "lt"
          "lv"
          "mk"
          "mr"
          "ms"
          "my"
          "nb-NO"
          "ne-NP"
          "nl"
          "nn-NO"
          "oc"
          "pa-IN"
          "pl"
          "pt-BR"
          "pt-PT"
          "rm"
          "ro"
          "ru"
          "sat"
          "sc"
          "sco"
          "si"
          "sk"
          "skr"
          "sl"
          "son"
          "sq"
          "sr"
          "sv-SE"
          "szl"
          "ta"
          "te"
          "tg"
          "th"
          "tl"
          "tr"
          "trs"
          "uk"
          "ur"
          "uz"
          "vi"
          "xh"
          "zh-CN"
          "zh-TW"
        ]
      );
    };

    nativeMessagingHosts.packages = lib.mkOption {
      default = [ ];

      description = ''
        Additional packages containing native messaging hosts that should be made available to Firefox extensions.
      '';

      type = lib.types.listOf lib.types.package;
    };

    policies = lib.mkOption {
      default = { };

      description = ''
        Group policies to install.

        See [Mozilla's documentation](https://mozilla.github.io/policy-templates/)
        for a list of available options.

        This can be used to install extensions declaratively! Check out the
        documentation of the `ExtensionSettings` policy for details.

        ${organisationInfo}
      '';

      type = policyFormat.type;
    };

    preferences = lib.mkOption {
      default = { };

      description = ''
        Preferences to set from `about:config`.

        Some of these might be able to be configured more ergonomically
        using policies.

        See [here](https://mozilla.github.io/policy-templates/#preferences) for allowed preferences.

        ${organisationInfo}
      '';

      example = lib.literalExpression ''
        {
          "browser.tabs.tabmanager.enabled" = false;
        }
      '';

      type =
        with lib.types;
        attrsOf (oneOf [
          bool
          int
          str
        ]);
    };

    preferencesStatus = lib.mkOption {
      default = "locked";

      description = ''
        The status of `firefox.preferences`.

        `status` can assume the following values:
        - `"default"`: Preferences appear as default.
        - `"locked"`: Preferences appear as default and can't be changed.
        - `"user"`: Preferences appear as changed.
        - `"clear"`: Value has no effect. Resets to factory defaults on each startup.
      '';

      type = lib.types.enum [
        "default"
        "locked"
        "user"
        "clear"
      ];
    };

    wrapperConfig = lib.mkOption {
      default = { };
      description = "Arguments to pass to Firefox wrapper";
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc =
      let
        policiesJSON = policyFormat.generate "firefox-policies.json" { inherit (cfg) policies; };
      in
      lib.mkIf (cfg.policies != { }) {
        "firefox/policies/policies.json".source = "${policiesJSON}";
      };

    environment.systemPackages = [
      cfg.finalPackage
    ];

    # Preferences are converted into a policy
    programs.firefox = {
      finalPackage = cfg.package.override (old: {
        cfg = (old.cfg or { }) // cfg.wrapperConfig;

        extraPrefsFiles =
          (old.extraPrefsFiles or [ ])
          ++ cfg.autoConfigFiles
          ++ [ (pkgs.writeText "firefox-autoconfig.js" cfg.autoConfig) ];

        nativeMessagingHosts = (old.nativeMessagingHosts or [ ]) ++ cfg.nativeMessagingHosts.packages;
      });

      policies = {
        DisableAppUpdate = true;

        ExtensionSettings = builtins.listToAttrs (
          map (
            lang:
            lib.attrsets.nameValuePair "langpack-${lang}@firefox.mozilla.org" {
              install_url = "https://releases.mozilla.org/pub/firefox/releases/${cfg.package.version}/linux-x86_64/xpi/${lang}.xpi";
              installation_mode = "normal_installed";
            }
          ) cfg.languagePacks
        );

        Preferences = (
          builtins.mapAttrs (_: value: {
            Status = cfg.preferencesStatus;
            Value = value;
          }) cfg.preferences
        );
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    linsui
  ];
}
