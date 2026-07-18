{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.olivetin;

  settingsFormat = pkgs.formats.yaml { };
in

{
  options.services.olivetin = {
    enable = lib.mkEnableOption "OliveTin";

    package = lib.mkOption {
      default =
        if lib.versionAtLeast config.system.stateVersion "26.05" then pkgs.olivetin-3k else pkgs.olivetin;

      defaultText = lib.literalExpression ''
        if lib.versionAtLeast config.system.stateVersion "26.05"
        then pkgs.olivetin-3k
        else pkgs.olivetin
      '';

      description = "The olivetin package to use.";
      type = lib.types.package;
    };

    extraConfigFiles = lib.mkOption {
      default = [ ];

      description = ''
        Config files to merge into the settings defined in [](#opt-services.olivetin.settings).
        This is useful to avoid putting secrets into the nix store.
        See <https://docs.olivetin.app/config.html> for more information.
      '';

      example = [ "/run/secrets/olivetin.yaml" ];
      type = lib.types.listOf lib.types.path;
    };

    group = lib.mkOption {
      default = "olivetin";
      description = "The group under which OliveTin runs.";
      type = lib.types.str;
    };

    path = lib.mkOption {
      defaultText = lib.literalExpression ''
        with pkgs; [ bash ]
      '';

      description = ''
        Packages added to the service's {env}`PATH`.
      '';

      type =
        with lib.types;
        listOf (oneOf [
          package
          str
        ]);
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration of OliveTin. See <https://docs.olivetin.app/config.html> for more information.
      '';

      type = lib.types.submodule {
        options = {
          ListenAddressSingleHTTPFrontend = lib.mkOption {
            default = "127.0.0.1:8000";

            description = ''
              The address to listen on for the internal "microproxy" frontend.
            '';

            example = "0.0.0.0:8000";
            type = lib.types.str;
          };
        };

        freeformType = settingsFormat.type;
      };
    };

    user = lib.mkOption {
      default = "olivetin";
      description = "The user account under which OliveTin runs.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.olivetin = {
      path = with pkgs; [ bash ];
    };

    systemd.services.olivetin = {
      inherit (cfg) path;

      after = [
        "network-online.target"
        "local-fs.target"
      ];

      description = "OliveTin";

      preStart = ''
        shopt -s nullglob

        tmp="$(mktemp)"
        ${lib.getExe pkgs.yq-go} eval-all '. as $item ireduce ({}; . *+ $item)' \
          ${settingsFormat.generate "olivetin-config.yaml" cfg.settings} \
          $CREDENTIALS_DIRECTORY/config-*.yaml > "$tmp"
        chmod -w "$tmp"

        mkdir -p /run/olivetin/config
        mv "$tmp" /run/olivetin/config/config.yaml
      '';

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} -configdir /run/olivetin/config";
        Group = cfg.group;
        LoadCredential = lib.imap0 (i: path: "config-${toString i}.yaml:${path}") cfg.extraConfigFiles;
        Restart = "always";
        RuntimeDirectory = "olivetin";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-online.target"
        "local-fs.target"
      ];
    };

    users.groups = lib.mkIf (cfg.group == "olivetin") { olivetin = { }; };

    users.users = lib.mkIf (cfg.user == "olivetin") {
      olivetin = {
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ defelo ];
}
