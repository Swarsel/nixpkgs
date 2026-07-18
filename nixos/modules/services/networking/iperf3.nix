{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.iperf3;

  api = {
    enable = mkEnableOption "iperf3 network throughput testing server";
    package = mkPackageOption pkgs "iperf3" { };

    affinity = mkOption {
      default = null;
      description = "CPU affinity for the process.";
      type = types.nullOr types.ints.unsigned;
    };

    authorizedUsersFile = mkOption {
      default = null;
      description = "Path to the configuration file containing authorized users credentials to run iperf tests.";
      type = types.nullOr types.path;
    };

    bind = mkOption {
      default = null;
      description = "Bind to the specific interface associated with the given address.";
      type = types.nullOr types.str;
    };

    debug = mkOption {
      default = false;
      description = "Emit debugging output.";
      type = types.bool;
    };

    extraFlags = mkOption {
      default = [ ];
      description = "Extra flags to pass to iperf3(1).";
      type = types.listOf types.str;
    };

    forceFlush = mkOption {
      default = false;
      description = "Force flushing output at every interval.";
      type = types.bool;
    };

    openFirewall = mkOption {
      default = false;
      description = "Open ports in the firewall for iperf3.";
      type = types.bool;
    };

    port = mkOption {
      default = 5201;
      description = "Server port to listen on for iperf3 client requests.";
      type = types.port;
    };

    rsaPrivateKey = mkOption {
      default = null;
      description = "Path to the RSA private key (not password-protected) used to decrypt authentication credentials from the client.";
      type = types.nullOr types.path;
    };

    verbose = mkOption {
      default = false;
      description = "Give more detailed output.";
      type = types.bool;
    };
  };

  imp = {

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.iperf3 = {
      after = [ "network.target" ];
      description = "iperf3 daemon";

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;

        ExecStart = ''
          ${lib.getExe cfg.package} \
            --server \
            --port ${toString cfg.port} \
            ${optionalString (cfg.affinity != null) "--affinity ${toString cfg.affinity}"} \
            ${optionalString (cfg.bind != null) "--bind ${cfg.bind}"} \
            ${optionalString (cfg.rsaPrivateKey != null) "--rsa-private-key-path ${cfg.rsaPrivateKey}"} \
            ${
              optionalString (
                cfg.authorizedUsersFile != null
              ) "--authorized-users-path ${cfg.authorizedUsersFile}"
            } \
            ${optionalString cfg.verbose "--verbose"} \
            ${optionalString cfg.debug "--debug"} \
            ${optionalString cfg.forceFlush "--forceflush"} \
            ${escapeShellArgs cfg.extraFlags}
        '';

        NoNewPrivileges = true;
        PrivateDevices = true;
        Restart = "on-failure";
        RestartSec = 2;
      };

      unitConfig.Documentation = "man:iperf3(1) https://iperf.fr/iperf-doc.php";
      wantedBy = [ "multi-user.target" ];
    };
  };
in
{
  options.services.iperf3 = api;
  config = mkIf cfg.enable imp;
}
