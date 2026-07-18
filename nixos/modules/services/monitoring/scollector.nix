{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.scollector;

  collectors = pkgs.runCommand "collectors" { preferLocalBuild = true; } ''
    mkdir -p $out
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        frequency: binaries:
        "mkdir -p $out/${frequency}\n"
        + (lib.concatStringsSep "\n" (
          map (path: "ln -s ${path} $out/${frequency}/$(basename ${path})") binaries
        ))
      ) cfg.collectors
    )}
  '';

  conf = pkgs.writeText "scollector.toml" ''
    Host = "${cfg.bosunHost}"
    ColDir = "${collectors}"
    ${cfg.extraConfig}
  '';

in
{

  options = {

    services.scollector = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to run scollector.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "scollector" { };

      bosunHost = lib.mkOption {
        default = "localhost:8070";

        description = ''
          Host and port of the bosun server that will store the collected
          data.
        '';

        type = lib.types.str;
      };

      collectors = lib.mkOption {
        default = { };

        description = ''
          An attribute set mapping the frequency of collection to a list of
          binaries that should be executed at that frequency. You can use "0"
          to run a binary forever.
        '';

        example = lib.literalExpression ''{ "0" = [ "''${postgresStats}/bin/collect-stats" ]; }'';
        type = with lib.types; attrsOf (listOf path);
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Extra scollector configuration added to the end of scollector.toml
        '';

        type = lib.types.lines;
      };

      extraOpts = lib.mkOption {
        default = [ ];

        description = ''
          Extra scollector command line options
        '';

        example = [ "-d" ];
        type = with lib.types; listOf str;
      };

      group = lib.mkOption {
        default = "scollector";

        description = ''
          Group account under which scollector runs.
        '';

        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "scollector";

        description = ''
          User account under which scollector runs.
        '';

        type = lib.types.str;
      };

    };

  };

  config = lib.mkIf config.services.scollector.enable {

    systemd.services.scollector = {
      description = "scollector metrics collector (part of Bosun)";

      path = [
        pkgs.coreutils
        pkgs.iproute2
      ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/scollector -conf=${conf} ${lib.concatStringsSep " " cfg.extraOpts}";
        Group = cfg.group;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.scollector.gid = config.ids.gids.scollector;

    users.users.scollector = {
      description = "scollector user";
      group = "scollector";
      uid = config.ids.uids.scollector;
    };

  };

}
