{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.pleroma;
in
{
  options = {
    services.pleroma = with lib; {
      enable = mkEnableOption "pleroma";
      package = mkPackageOption pkgs "pleroma" { };

      configs = mkOption {
        description = ''
          Pleroma public configuration.

          This list gets appended from left to
          right into /etc/pleroma/config.exs. Elixir evaluates its
          configuration imperatively, meaning you can override a
          setting by appending a new str to this NixOS option list.

          *DO NOT STORE ANY PLEROMA SECRET
          HERE*, use
          [services.pleroma.secretConfigFile](#opt-services.pleroma.secretConfigFile)
          instead.

          This setting is going to be stored in a file part of
          the Nix store. The Nix store being world-readable, it's not
          the right place to store any secret

          Have a look to Pleroma section in the NixOS manual for more
          information.
        '';

        type = with types; listOf str;
      };

      group = mkOption {
        default = "pleroma";
        description = "Group account under which pleroma runs.";
        type = types.str;
      };

      secretConfigFile = mkOption {
        default = "/var/lib/pleroma/secrets.exs";

        description = ''
          Path to the file containing your secret pleroma configuration.

          *DO NOT POINT THIS OPTION TO THE NIX
          STORE*, the store being world-readable, it'll
          compromise all your secrets.
        '';

        type = types.str;
      };

      stateDir = mkOption {
        default = "/var/lib/pleroma";
        description = "Directory where the pleroma service will save the uploads and static files.";
        readOnly = true;
        type = types.str;
      };

      user = mkOption {
        default = "pleroma";
        description = "User account under which pleroma runs.";
        type = types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."/pleroma/config.exs".text = ''
      ${lib.concatMapStrings (x: "${x}") cfg.configs}

      # The lau/tzdata library is trying to download the latest
      # timezone database in the OTP priv directory by default.
      # This directory being in the store, it's read-only.
      # Setting that up to a more appropriate location.
      config :tzdata, :data_dir, "/var/lib/pleroma/elixir_tzdata_data"

      import_config "${cfg.secretConfigFile}"
    '';

    environment.systemPackages = [ cfg.package ];

    systemd.services =
      let
        commonSystemdServiceConfig = {
          CapabilityBoundingSet = "~CAP_SYS_ADMIN";
          Group = cfg.group;
          NoNewPrivileges = true;
          PrivateDevices = false;
          # Systemd sandboxing directives.
          # Taken from the upstream contrib systemd service at
          # pleroma/installation/pleroma.service
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "full";
          StateDirectory = "pleroma pleroma/static pleroma/uploads";
          StateDirectoryMode = "700";
          User = cfg.user;
          WorkingDirectory = "~";
        };

      in
      {
        pleroma = {
          after = [ "pleroma-migrations.service" ];
          description = "Pleroma social network";
          environment.RELEASE_COOKIE = "/var/lib/pleroma/.cookie";
          # disksup requires bash
          path = [ pkgs.bash ];
          restartTriggers = [ config.environment.etc."/pleroma/config.exs".source ];

          serviceConfig = commonSystemdServiceConfig // {
            ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
            ExecStart = "${cfg.package}/bin/pleroma start";
            ExecStop = "${cfg.package}/bin/pleroma stop";
            Type = "exec";
          };

          wantedBy = [ "multi-user.target" ];
          wants = [ "pleroma-migrations.service" ];
        };

        pleroma-migrations = {
          after = [
            "network-online.target"
            "postgresql.target"
          ];

          description = "Pleroma social network migrations";
          environment.RELEASE_COOKIE = "/var/lib/pleroma/.cookie";
          # disksup requires bash
          path = [ pkgs.bash ];

          serviceConfig = commonSystemdServiceConfig // {
            # Checking the conf file is there then running the database
            # migration before each service start, just in case there are
            # some pending ones.
            #
            # It's sub-optimal as we'll always run this, even if pleroma
            # has not been updated. But the no-op process is pretty fast.
            # Better be safe than sorry migration-wise.
            ExecStart =
              let
                preScript = pkgs.writers.writeBashBin "pleroma-migrations" ''
                  if [ ! -f /var/lib/pleroma/.cookie ]
                  then
                    echo "Creating cookie file"
                    dd if=/dev/urandom bs=1 count=16 | hexdump -e '16/1 "%02x"' > /var/lib/pleroma/.cookie
                  fi
                  ${cfg.package}/bin/pleroma_ctl migrate
                '';
              in
              "${preScript}/bin/pleroma-migrations";

            Type = "oneshot";
          };

          wantedBy = [ "pleroma.service" ];
          wants = [ "network-online.target" ];
        };
      };

    users = {
      groups."${cfg.group}" = { };

      users."${cfg.user}" = {
        description = "Pleroma user";
        group = cfg.group;
        home = cfg.stateDir;
        isSystemUser = true;
      };
    };
  };

  meta.doc = ./pleroma.md;
  meta.maintainers = with lib.maintainers; [ picnoir ];
}
