{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.vmagent;
  settingsFormat = pkgs.formats.yaml { };

  startCLIList = [
    "${cfg.package}/bin/vmagent"
  ]
  ++ lib.optionals (cfg.remoteWrite.url != null) [
    "-remoteWrite.url=${cfg.remoteWrite.url}"
    "-remoteWrite.tmpDataPath=%C/vmagent/remote_write_tmp"
  ]
  ++ lib.optional (
    cfg.remoteWrite.basicAuthUsername != null
  ) "-remoteWrite.basicAuth.username=${cfg.remoteWrite.basicAuthUsername}"
  ++ lib.optional (
    cfg.remoteWrite.basicAuthPasswordFile != null
  ) "-remoteWrite.basicAuth.passwordFile=\${CREDENTIALS_DIRECTORY}/remote_write_basic_auth_password"
  ++ cfg.extraArgs;
  prometheusConfigYml = checkedConfig (
    settingsFormat.generate "prometheusConfig.yaml" cfg.prometheusConfig
  );

  checkedConfig =
    file:
    if cfg.checkConfig then
      pkgs.runCommand "checked-config" { nativeBuildInputs = [ cfg.package ]; } ''
        ln -s ${file} $out
        ${lib.escapeShellArgs startCLIList} -promscrape.config=${file} -dryRun
      ''
    else
      file;
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "vmagent"
      "dataDir"
    ] "dataDir has been deprecated in favor of systemd provided CacheDirectory")
    (lib.mkRemovedOptionModule [
      "services"
      "vmagent"
      "user"
    ] "user has been deprecated in favor of systemd DynamicUser")
    (lib.mkRemovedOptionModule [
      "services"
      "vmagent"
      "group"
    ] "group has been deprecated in favor of systemd DynamicUser")
    (lib.mkRenamedOptionModule
      [ "services" "vmagent" "remoteWriteUrl" ]
      [ "services" "vmagent" "remoteWrite" "url" ]
    )
  ];

  options.services.vmagent = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable VictoriaMetrics's `vmagent`.

        `vmagent` efficiently scrape metrics from Prometheus-compatible exporters
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "vmagent" { };

    checkConfig = lib.mkOption {
      default = true;

      description = ''
        Check configuration.

        If you use credentials stored in external files (`environmentFile`, etc),
        they will not be visible  and it will report errors, despite a correct configuration.
      '';

      type = lib.types.bool;
    };

    extraArgs = lib.mkOption {
      default = [ ];

      description = ''
        Extra args to pass to `vmagent`. See the docs:
        <https://docs.victoriametrics.com/vmagent.html#advanced-usage>
        or {command}`vmagent -help` for more information.
      '';

      type = lib.types.listOf lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether to open the firewall for the default ports.
      '';

      type = lib.types.bool;
    };

    prometheusConfig = lib.mkOption {
      description = ''
        Config for prometheus style metrics
      '';

      type = lib.types.submodule { freeformType = settingsFormat.type; };
    };

    remoteWrite = {
      basicAuthPasswordFile = lib.mkOption {
        default = null;

        description = ''
          File that contains the Basic Auth password used to connect to remote_write endpoint
        '';

        type = lib.types.nullOr lib.types.str;
      };

      basicAuthUsername = lib.mkOption {
        default = null;

        description = ''
          Basic Auth username used to connect to remote_write endpoint
        '';

        type = lib.types.nullOr lib.types.str;
      };

      url = lib.mkOption {
        default = null;

        description = ''
          Endpoint for prometheus compatible remote_write
        '';

        type = lib.types.nullOr lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ 8429 ];

    systemd.services.vmagent = {
      after = [ "network.target" ];
      description = "vmagent system service";

      serviceConfig = {
        CacheDirectory = "vmagent";
        DynamicUser = true;

        ExecStart = lib.escapeShellArgs (
          startCLIList
          ++ lib.optionals (cfg.prometheusConfig != { }) [ "-promscrape.config=${prometheusConfigYml}" ]
        );

        Group = "vmagent";

        LoadCredential = lib.optional (cfg.remoteWrite.basicAuthPasswordFile != null) [
          "remote_write_basic_auth_password:${cfg.remoteWrite.basicAuthPasswordFile}"
        ];

        Restart = "on-failure";
        Type = "simple";
        User = "vmagent";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
