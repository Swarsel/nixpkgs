{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  inherit (lib) types;
  cfg = config.services.kiwix-serve;
  # Create a directory containing symlinks to ZIM files
  mkLibrary =
    library:
    let
      libraryEntries = lib.mapAttrsToList (name: path: {
        inherit path;
        name = "${name}.zim";
      }) library;

      zimsDrv = pkgs.linkFarm "zims" libraryEntries;

      files = map (entry: "${zimsDrv}/${entry.name}") libraryEntries;
    in
    {
      inherit files;
      derivation = zimsDrv;
    };
in
{
  options = {
    services.kiwix-serve = {
      enable = lib.mkEnableOption "the kiwix-serve server";
      package = lib.mkPackageOption pkgs "kiwix-tools" { };

      address = lib.mkOption {
        default = "all";

        description = ''
          Listen only on the specified IP address.
          Specify "ipv4", "ipv6" or "all" to listen on all IPv4, IPv6, or both types of addresses, respectively.
        '';

        example = "ipv4";
        type = types.str;
      };

      extraArgs = lib.mkOption {
        default = [ ];
        description = "Extra arguments to pass to kiwix-serve.";

        example = [
          "--verbose"
          "--skipInvalid"
        ];

        type = types.listOf types.str;
      };

      library = lib.mkOption {
        default = { };

        description = ''
          A set of ZIM files to serve. The key is used as the name for the ZIM files
          (e.g. in the example, the files will be served as `wikipedia.zim` and `nix.zim`).

          Exclusive with [services.kiwix-serve.libraryPath](#opt-services.kiwix-serve.libraryPath).
        '';

        example = lib.literalExpression (
          lib.removeSuffix "\n" ''
            {
              wikipedia = "/data/wikipedia_en_all_maxi_2026-02.zim";
              nix = pkgs.fetchurl {
                url = "https://download.kiwix.org/zim/devdocs/devdocs_en_nix_2026-01.zim";
                hash = "sha256-QxB9qDKSzzEU8t4droI08BXdYn+HMVkgiJMO3SoGTqM=";
              };
            }
          ''
        );

        type = types.attrsOf types.path;
      };

      libraryPath = lib.mkOption {
        default = null;

        description = ''
          An XML library file listing ZIM files to serve.
          For more information, see <https://wiki.kiwix.org/wiki/Kiwix-manage>.

          Exclusive with [services.kiwix-serve.library](#opt-services.kiwix-serve.library).
        '';

        example = "/data/library.xml";
        type = types.nullOr types.path;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Whether to open the firewall for the configured port.";
        type = types.bool;
      };

      port = lib.mkOption {
        default = 8080;
        description = "The port on which to run kiwix-serve.";
        type = types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.library == { }) != (cfg.libraryPath == null);
        message = "Exactly one of services.kiwix-serve.library or services.kiwix-serve.libraryPath must be provided.";
      }
    ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.kiwix-serve =
      let
        library = mkLibrary cfg.library;
      in
      {
        after = [ "network.target" ];
        description = "ZIM file HTTP server";
        documentation = [ "https://kiwix-tools.readthedocs.io/en/latest/kiwix-serve.html" ];

        serviceConfig = {
          CapabilityBoundingSet = "";
          DeviceAllow = "";
          DynamicUser = true;

          ExecStart = utils.escapeSystemdExecArgs (
            [
              (lib.getExe' cfg.package "kiwix-serve")
              "--address"
              cfg.address
              "--port"
              cfg.port
            ]
            ++ lib.optionals (cfg.libraryPath != null) [
              "--library"
              cfg.libraryPath
            ]
            ++ lib.optionals (cfg.library != { }) library.files
            ++ cfg.extraArgs
          );

          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RemoveIPC = true;
          Restart = "on-failure";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "~@resources"
          ];

          Type = "exec";
          UMask = "0077";
        };

        wantedBy = [ "multi-user.target" ];
      };
  };

  meta = {
    maintainers = with lib.maintainers; [ MysteryBlokHed ];
  };
}
