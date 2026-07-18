# Systemd services for openvswitch

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.virtualisation.vswitch;

in
{

  imports = [
    (mkRemovedOptionModule [ "virtualisation" "vswitch" "ipsec" ] ''
      OpenVSwitch IPSec functionality has been removed, because it depended on racoon,
      which was removed from nixpkgs, because it was abanoded upstream.
    '')
  ];

  options.virtualisation.vswitch = {
    enable = mkOption {
      default = false;

      description = ''
        Whether to enable Open vSwitch. A configuration daemon (ovs-server)
        will be started.
      '';

      type = types.bool;
    };

    package = mkPackageOption pkgs "openvswitch" { };

    resetOnStart = mkOption {
      default = false;

      description = ''
        Whether to reset the Open vSwitch configuration database to a default
        configuration on every start of the systemd `ovsdb.service`.
      '';

      type = types.bool;
    };
  };

  config = mkIf cfg.enable (
    let

      # Where the communication sockets live
      runDir = "/run/openvswitch";

      # The path to the an initialized version of the database
      db = pkgs.stdenv.mkDerivation {
        buildInputs = [
          cfg.package
        ];

        buildPhase = "true";
        dontUnpack = true;
        installPhase = "mkdir -p $out";
        name = "vswitch.db";
      };

    in
    {
      boot.extraModulePackages = [ cfg.package ];

      boot.kernelModules = [
        "tun"
        "openvswitch"
      ];

      environment.systemPackages = [ cfg.package ];

      systemd.services.ovs-vswitchd = {
        after = [ "ovsdb.service" ];
        bindsTo = [ "ovsdb.service" ];
        description = "Open_vSwitch Daemon";
        path = [ cfg.package ];

        serviceConfig = {
          ExecStart = ''
            ${cfg.package}/bin/ovs-vswitchd \
            --pidfile=/run/openvswitch/ovs-vswitchd.pid \
            --detach
          '';

          PIDFile = "/run/openvswitch/ovs-vswitchd.pid";
          Restart = "always";
          RestartSec = 3;
          # Use service type 'forking' to correctly determine when vswitchd is ready.
          Type = "forking";
        };

        wantedBy = [ "multi-user.target" ];
      };

      systemd.services.ovsdb = {
        description = "Open_vSwitch Database Server";
        path = [ cfg.package ];

        postStart = ''
          ${cfg.package}/bin/ovs-vsctl --timeout 3 --retry --no-wait init
        '';

        # Create the config database
        preStart = ''
          mkdir -p ${runDir}
          mkdir -p /var/db/openvswitch
          chmod +w /var/db/openvswitch
          ${optionalString cfg.resetOnStart "rm -f /var/db/openvswitch/conf.db"}
          if [[ ! -e /var/db/openvswitch/conf.db ]]; then
            ${cfg.package}/bin/ovsdb-tool create \
              "/var/db/openvswitch/conf.db" \
              "${cfg.package}/share/openvswitch/vswitch.ovsschema"
          fi
          chmod -R +w /var/db/openvswitch
          if ${cfg.package}/bin/ovsdb-tool needs-conversion /var/db/openvswitch/conf.db | grep -q "yes"
          then
            echo "Performing database upgrade"
            ${cfg.package}/bin/ovsdb-tool convert /var/db/openvswitch/conf.db
          else
            echo "Database already up to date"
          fi
        '';

        restartTriggers = [
          db
          cfg.package
        ];

        serviceConfig = {
          ExecStart = ''
            ${cfg.package}/bin/ovsdb-server \
              --remote=punix:${runDir}/db.sock \
              --private-key=db:Open_vSwitch,SSL,private_key \
              --certificate=db:Open_vSwitch,SSL,certificate \
              --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
              --unixctl=ovsdb.ctl.sock \
              --pidfile=/run/openvswitch/ovsdb.pid \
              --detach \
              /var/db/openvswitch/conf.db
          '';

          PIDFile = "/run/openvswitch/ovsdb.pid";
          Restart = "always";
          RestartSec = 3;
          # Use service type 'forking' to correctly determine when ovsdb-server is ready.
          Type = "forking";
        };

        wantedBy = [ "multi-user.target" ];
      };

    }
  );

  meta.maintainers = with maintainers; [ netixx ];

}
