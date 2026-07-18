{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.stirling-pdf;
in
{
  options.services.stirling-pdf = {
    enable = lib.mkEnableOption "the stirling-pdf service";
    package = lib.mkPackageOption pkgs "stirling-pdf" { };

    environment = lib.mkOption {
      default = { };

      description = ''
        Environment variables for the stirling-pdf app.
        See <https://github.com/Stirling-Tools/Stirling-PDF#customisation> for available options.
      '';

      example = {
        INSTALL_BOOK_AND_ADVANCED_HTML_OPS = true;
        SERVER_PORT = 8080;
      };

      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.str
          lib.types.int
          lib.types.bool
        ]
      );
    };

    environmentFiles = lib.mkOption {
      default = [ ];

      description = ''
        Files containing additional environment variables to pass to Stirling PDF.
        Secrets should be added in environmentFiles instead of environment.
      '';

      type = lib.types.listOf lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.stirling-pdf = {
      environment = lib.mapAttrs (
        _: v: if (builtins.isBool v) then (lib.boolToString v) else (toString v)
      ) cfg.environment;

      # following https://docs.stirlingpdf.com/Installation/Unix%20Installation
      path =
        with pkgs;
        [
          # `which` is used to test command availability
          # See https://github.com/Stirling-Tools/Stirling-PDF/blob/main/app/core/src/main/java/stirling/software/SPDF/config/ExternalAppDepConfig.java#L262
          which
          unpaper
          libreoffice
          qpdf
          ocrmypdf
          poppler-utils
          unoconv
          pngquant
          tesseract
          (python3.withPackages (
            p: with p; [
              weasyprint
              opencv-python-headless
            ]
          ))
          ghostscript_headless
        ]
        ++ lib.optional (cfg.environment.INSTALL_BOOK_AND_ADVANCED_HTML_OPS or "false" == "true") calibre;

      serviceConfig = {
        BindReadOnlyPaths = [ "${pkgs.tesseract}/share/tessdata:/usr/share/tessdata" ];
        CacheDirectory = "stirling-pdf";
        # Hardening
        CapabilityBoundingSet = "";
        DynamicUser = true;
        Environment = [ "HOME=%S/stirling-pdf" ];
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = lib.getExe cfg.package;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
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

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RuntimeDirectory = "stirling-pdf";
        StateDirectory = "stirling-pdf";
        SuccessExitStatus = 143;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "~@cpu-emulation @debug @keyring @mount @obsolete @privileged @clock @setuid @chown"
        ];

        UMask = "0077";
        User = "stirling-pdf";
        WorkingDirectory = "/var/lib/stirling-pdf";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    DCsunset
    timhae
  ];
}
