{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    literalExpression
    makeLibraryPath
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    mkRemovedOptionModule
    optional
    types
    ;

  cfg = config.services.aesmd;
  opt = options.services.aesmd;

  sgx-psw = cfg.package;

  configFile =
    with cfg.settings;
    pkgs.writeText "aesmd.conf" (
      concatStringsSep "\n" (
        optional (whitelistUrl != null) "whitelist url = ${whitelistUrl}"
        ++ optional (proxy != null) "aesm proxy = ${proxy}"
        ++ optional (proxyType != null) "proxy type = ${proxyType}"
        ++ optional (defaultQuotingType != null) "default quoting type = ${defaultQuotingType}"
        ++
          # Newline at end of file
          [ "" ]
      )
    );
in
{
  imports = [
    (mkRemovedOptionModule [ "services" "aesmd" "debug" ] ''
      Enable debug mode by overriding the aesmd package directly:

          services.aesmd.package = pkgs.sgx-psw.override { debug = true; };
    '')
  ];

  options.services.aesmd = {
    enable = mkEnableOption "Intel's Architectural Enclave Service Manager (AESM) for Intel SGX";
    package = mkPackageOption pkgs "sgx-psw" { };

    environment = mkOption {
      default = { };
      description = "Additional environment variables to pass to the AESM service.";

      # Example environment variable for `sgx-azure-dcap-client` provider library
      example = {
        AZDCAP_COLLATERAL_VERSION = "v2";
        AZDCAP_DEBUG_LOG_LEVEL = "INFO";
      };

      type = with types; attrsOf str;
    };

    quoteProviderLibrary = mkOption {
      default = null;
      description = "Custom quote provider library to use.";
      example = literalExpression "pkgs.sgx-azure-dcap-client";
      type = with types; nullOr path;
    };

    settings = mkOption {
      default = { };
      description = "AESM configuration";

      type = types.submodule {
        options.defaultQuotingType = mkOption {
          default = null;
          description = "Attestation quote type.";
          example = "ecdsa_256";

          type =
            with types;
            nullOr (enum [
              "ecdsa_256"
              "epid_linkable"
              "epid_unlinkable"
            ]);
        };

        options.proxy = mkOption {
          default = null;
          description = "HTTP network proxy.";
          example = "http://proxy_url:1234";
          type = with types; nullOr str;
        };

        options.proxyType = mkOption {
          default = if (cfg.settings.proxy != null) then "manual" else null;

          defaultText = literalExpression ''
            if (config.${opt.settings}.proxy != null) then "manual" else null
          '';

          description = ''
            Type of proxy to use. The `default` uses the system's default proxy.
            If `direct` is given, uses no proxy.
            A value of `manual` uses the proxy from
            {option}`services.aesmd.settings.proxy`.
          '';

          example = "default";

          type =
            with types;
            nullOr (enum [
              "default"
              "direct"
              "manual"
            ]);
        };

        options.whitelistUrl = mkOption {
          default = null;
          description = "URL to retrieve authorized Intel SGX enclave signers.";
          example = "http://whitelist.trustedservices.intel.com/SGX/LCWL/Linux/sgx_white_list_cert.bin";
          type = with types; nullOr str;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(config.boot.specialFileSystems."/dev".options ? "noexec");
        message = "SGX requires exec permission for /dev";
      }
    ];

    hardware.cpu.intel.sgx.provision.enable = true;

    systemd.services.aesmd =
      let
        storeAesmFolder = "${sgx-psw}/aesm";
        # Hardcoded path AESM_DATA_FOLDER in psw/ae/aesm_service/source/oal/linux/aesm_util.cpp
        aesmDataFolder = "/var/opt/aesmd/data";
      in
      {
        after = [
          "auditd.service"
          "network.target"
        ];

        description = "Intel Architectural Enclave Service Manager";

        environment = {
          AESM_PATH = storeAesmFolder;
          LD_LIBRARY_PATH = makeLibraryPath [ cfg.quoteProviderLibrary ];
          NAME = "aesm_service";
        }
        // cfg.environment;

        serviceConfig = {
          BindPaths = [
            # Hardcoded path CONFIG_SOCKET_PATH in psw/ae/aesm_service/source/core/ipc/SocketConfig.h
            "%t/aesmd:/var/run/aesmd"
            "%S/aesmd:/var/opt/aesmd"
          ];

          BindReadOnlyPaths = [
            builtins.storeDir
            # Hardcoded path AESM_CONFIG_FILE in psw/ae/aesm_service/source/utils/aesm_config.cpp
            "${configFile}:/etc/aesmd.conf"
          ];

          CapabilityBoundingSet = "";

          DeviceAllow = [
            # in-tree driver
            "/dev/sgx_enclave rw"
            "/dev/sgx_provision rw"
          ];

          DevicePolicy = "closed";
          DynamicUser = true;
          ExecReload = ''${pkgs.coreutils}/bin/kill -SIGHUP "$MAINPID"'';
          ExecStart = "${sgx-psw}/bin/aesm_service --no-daemon";

          # Run with elevated privileges to create /var/opt/aesmd/... before
          # dropping to DynamicUser.
          ExecStartPre = ''
            +${lib.getExe' pkgs.coreutils "install"} -m 644 -D \
                "${storeAesmFolder}/data/white_list_cert_to_be_verify.bin" \
                "${aesmDataFolder}/white_list_cert_to_be_verify.bin"
          '';

          Group = "sgx";
          KeyringMode = "private";
          LockPersonality = true;
          # True breaks stuff
          MemoryDenyWriteExecute = false;
          NoNewPrivileges = true;
          NotifyAccess = "none";
          # PrivateDevices=true will mount /dev noexec which breaks AESM
          PrivateDevices = false;
          PrivateMounts = true;
          # Requires Internet access for attestation
          PrivateNetwork = false;
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
          RestartSec = "15s";

          RestrictAddressFamilies = [
            # Allocates the socket /var/run/aesmd/aesm.socket
            "AF_UNIX"
            # Makes HTTPS requests to the Intel PCCS service (or a cache).
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          # --- Hardening ---
          RootDirectory = "%t/aesmd";
          RuntimeDirectory = "aesmd";
          RuntimeDirectoryMode = "0750";
          StateDirectory = "aesmd";
          StateDirectoryMode = "0700";

          SupplementaryGroups = [
            config.hardware.cpu.intel.sgx.provision.group
          ];

          SystemCallArchitectures = "native";
          SystemCallErrorNumber = "EPERM";

          # needs the ipc syscall in order to run
          SystemCallFilter = [
            "@system-service"
            "~@aio"
            "~@chown"
            "~@clock"
            "~@cpu-emulation"
            "~@debug"
            "~@keyring"
            "~@memlock"
            "~@module"
            "~@mount"
            "~@privileged"
            "~@raw-io"
            "~@reboot"
            "~@resources"
            "~@setuid"
            "~@swap"
            "~@sync"
            "~@timer"
          ];

          Type = "simple";
          UMask = "0066";
          WorkingDirectory = storeAesmFolder;
        };

        # Ensure the SGX application enclave device is available
        unitConfig.AssertPathExists = [ "/dev/sgx_enclave" ];
        wantedBy = [ "multi-user.target" ];
      };
  };
}
